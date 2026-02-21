import "dotenv/config";
import express from "express";
import http from "http";
import { WebSocketServer } from "ws";
import os from "os";
import fs from "fs";
import path from "path";
import yaml from "js-yaml";
import crypto from "crypto";
import { spawn } from "child_process";

const PORT = Number(process.env.PORT || 8787);

const app = express();
app.use(express.json({ limit: "50mb" }));
app.use(express.static("public"));

const server = http.createServer(app);
const wss = new WebSocketServer({ server, path: "/ws" });

const BASE = path.join(os.homedir(), ".local", "share", "chromialux", "sessions");
fs.mkdirSync(BASE, { recursive: true });

function now() { return Date.now(); }
function uid(prefix="id") { return `${prefix}_${now()}_${crypto.randomBytes(3).toString("hex")}`; }
function sha(s) { return crypto.createHash("sha256").update(s).digest("hex"); }
function safeJson(s){ try { return JSON.parse(s); } catch { return null; } }

function sessionDir(sessionId){ return path.join(BASE, sessionId); }
function ensureSessionDirs(sessionId){
  const dir = sessionDir(sessionId);
  fs.mkdirSync(dir, { recursive: true });
  fs.mkdirSync(path.join(dir, "captures"), { recursive: true });
  fs.mkdirSync(path.join(dir, "assets"), { recursive: true });
  return dir;
}

function appendJsonl(file, obj){
  fs.appendFileSync(file, JSON.stringify(obj) + "\n");
}

function writeState(sessionId, state){
  const dir = ensureSessionDirs(sessionId);
  fs.writeFileSync(path.join(dir, "state.json"), JSON.stringify(state, null, 2));
}

function readState(sessionId){
  const p = path.join(sessionDir(sessionId), "state.json");
  if (!fs.existsSync(p)) return null;
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function listSessions(){
  if (!fs.existsSync(BASE)) return [];
  return fs.readdirSync(BASE).filter(d => fs.existsSync(path.join(BASE,d,"state.json"))).sort().reverse();
}

// --- Macro parsing: extract first ```chromialux-macro ... ```
function extractMacroBlock(text){
  const re = /```chromialux-macro\s*([\s\S]*?)```/m;
  const m = re.exec(text || "");
  if (!m) return null;
  try {
    const obj = yaml.load(m[1]);
    if (!obj || typeof obj !== "object") return null;
    return obj;
  } catch {
    return null;
  }
}

// --- Dispatch SSH via scp
function scpDispatch(sessionId){
  if ((process.env.DISPATCH_MODE || "ssh") !== "ssh") return;

  const host = process.env.SSH_HOST;
  const port = process.env.SSH_PORT || "22";
  const user = process.env.SSH_USER;
  const remoteBase = process.env.SSH_REMOTE_PATH;
  const keyPath = process.env.SSH_KEY_PATH;

  if (!host || !user || !remoteBase) return;

  const dir = sessionDir(sessionId);
  const remote = `${user}@${host}:${remoteBase}/session_${sessionId}`;

  const sshArgs = [
    "-p", String(port),
    ...(keyPath ? ["-i", keyPath] : []),
    `${user}@${host}`,
    `mkdir -p "${remoteBase}/session_${sessionId}"`
  ];
  spawn("ssh", sshArgs, { stdio: "ignore" });

  const scpArgs = [
    "-r",
    "-P", String(port),
    ...(keyPath ? ["-i", keyPath] : []),
    dir,
    remote
  ];
  spawn("scp", scpArgs, { stdio: "ignore" });
}

// --- WebSocket helpers
function wsSend(ws, obj){
  if (ws.readyState === 1) ws.send(JSON.stringify(obj));
}

// Simple mock "agent"
async function runMock(input){
  await new Promise(r => setTimeout(r, 400 + Math.random()*700));
  return `MOCK_REPLY\n${input.slice(0, 800)}`;
}

// Macro executor
async function execMacro(ws, ctx){
  const { sessionId, agent, incomingText } = ctx;

  const macro = extractMacroBlock(incomingText);
  const log = [];
  if (!macro) {
    log.push("NO_MACRO_BLOCK_FOUND");
    return { ok: true, log, macro: null };
  }

  const steps = Array.isArray(macro.steps) ? macro.steps : [];
  const captureCfg = macro.capture || {};

  if (captureCfg.before) {
    const tokenId = uid("tok");
    wsSend(ws, { type:"capture_request", sessionId, tokenId, agentId: agent.id, label:"macro_before", roi: agent.roi || null });
    log.push("CAPTURE_BEFORE_REQUESTED");
  }

  for (const s of steps) {
    const type = String(s?.type || "").toLowerCase();
    if (!type) continue;

    if (type === "wait") {
      const ms = Math.max(0, Number(s.ms || 0));
      await new Promise(r => setTimeout(r, ms));
      log.push(`WAIT ${ms}ms`);
      continue;
    }

    if (type === "checkpoint") {
      const label = String(s.label || "checkpoint");
      wsSend(ws, { type:"checkpoint", sessionId, agentId: agent.id, label });
      log.push(`CHECKPOINT ${label}`);
      continue;
    }

    if (type === "screenshot") {
      const tokenId = uid("tok");
      const label = String(s.label || "shot");
      wsSend(ws, { type:"capture_request", sessionId, tokenId, agentId: agent.id, label, roi: agent.roi || null });
      log.push(`SCREENSHOT_REQUEST ${label}`);
      continue;
    }

    if (type === "ssh") {
      const cmd = String(s.cmd || "");
      log.push(`SSH_CMD ${cmd}`);
      continue;
    }

    if (type === "emit_proof") {
      const text = String(s.text || "");
      wsSend(ws, { type:"emit_proof", sessionId, agentId: agent.id, text });
      log.push("EMIT_PROOF");
      continue;
    }

    log.push(`UNKNOWN_STEP ${type}`);
  }

  if (captureCfg.after) {
    const tokenId = uid("tok");
    wsSend(ws, { type:"capture_request", sessionId, tokenId, agentId: agent.id, label:"macro_after", roi: agent.roi || null });
    log.push("CAPTURE_AFTER_REQUESTED");
  }

  return { ok: true, log, macro };
}

function buildTranscript(dir){
  const archivePath = path.join(dir, "archive.jsonl");
  if (!fs.existsSync(archivePath)) return "";
  const lines = fs.readFileSync(archivePath, "utf8").trim().split("\n").filter(Boolean);
  const seen = new Set();
  const out = [];
  for (const line of lines) {
    const obj = safeJson(line);
    if (!obj?.text) continue;
    const h = obj.hash || sha(obj.text);
    if (seen.has(h)) continue;
    seen.add(h);
    out.push(`### ${obj.agentName || obj.agentId || "agent"}\n${obj.text}\n`);
  }
  return out.join("\n");
}

// --- WS main
wss.on("connection", (ws) => {
  wsSend(ws, { type:"hello", sessions: listSessions().slice(0, 20) });

  ws.on("message", async (buf) => {
    const msg = safeJson(buf.toString("utf8"));
    if (!msg?.type) return;

    if (msg.type === "session_new") {
      const sessionId = uid("sess");
      ensureSessionDirs(sessionId);
      const state = {
        sessionId,
        createdAt: now(),
        agents: [],
        routing: { routeMode:"BROADCAST", loops:0, loopType:"PASSES", feedback:"PROMPT" }
      };
      writeState(sessionId, state);
      wsSend(ws, { type:"session_ready", sessionId, state });
      return;
    }

    if (msg.type === "session_load") {
      const sessionId = String(msg.sessionId || "");
      const state = readState(sessionId);
      if (!state) {
        wsSend(ws, { type:"error", error:"SESSION_NOT_FOUND" });
        return;
      }
      wsSend(ws, { type:"session_ready", sessionId, state });
      return;
    }

    if (msg.type === "session_save") {
      const sessionId = String(msg.sessionId || "");
      if (!sessionId) return;
      writeState(sessionId, msg.state || {});
      wsSend(ws, { type:"saved", sessionId });
      return;
    }

    if (msg.type === "capture_result") {
      const sessionId = String(msg.sessionId || "");
      const dir = ensureSessionDirs(sessionId);
      const { tokenId, agentId, label, dataUrl } = msg;

      if (typeof dataUrl !== "string" || !dataUrl.startsWith("data:image/")) return;

      const base64 = dataUrl.split(",")[1] || "";
      const bin = Buffer.from(base64, "base64");
      const filename = `${tokenId}_${agentId}_${label || "cap"}.png`;
      const p = path.join(dir, "captures", filename);
      fs.writeFileSync(p, bin);

      const tok = {
        tokenId: uid("tok"),
        ts: now(),
        type: "SCREENSHOT",
        agentId,
        path: `captures/${filename}`,
        scope: "archive"
      };
      appendJsonl(path.join(dir, "archive.jsonl"), tok);
      wsSend(ws, { type:"capture_saved", path: tok.path });
      return;
    }

    if (msg.type === "emit_proof") {
      const sessionId = String(msg.sessionId || "");
      const dir = ensureSessionDirs(sessionId);
      const text = String(msg.text || "");
      const token = {
        tokenId: uid("tok"),
        ts: now(),
        type: "PROOF",
        agentId: String(msg.agentId || ""),
        text,
        hash: sha(text),
        scope: "public"
      };
      appendJsonl(path.join(dir, "public.jsonl"), token);
      wsSend(ws, { type:"proof_saved" });
      return;
    }

    if (msg.type === "send_prompt") {
      const sessionId = String(msg.sessionId || "");
      const dir = ensureSessionDirs(sessionId);

      const agents = Array.isArray(msg.agents) ? msg.agents : [];
      const prompt = String(msg.text || "").trim();

      if (prompt) {
        const t = {
          tokenId: uid("tok"),
          ts: now(),
          type: "PROMPT",
          text: prompt,
          hash: sha(prompt),
          scope: "archive"
        };
        appendJsonl(path.join(dir, "archive.jsonl"), t);
      }

      for (const a of agents) {
        if (!a?.rx) continue;
        if (Number(a.rxCountdown || 0) <= 0) continue;

        const agentName = a.name || a.id;
        wsSend(ws, { type:"agent_started", agentId: a.id, name: agentName });

        let replyText = "";
        if (a.macro) {
          const r = await execMacro(ws, { sessionId, agent: a, incomingText: prompt });
          replyText = `MACRO_EXEC\n${(r.log || []).join("\n")}`;
        } else {
          replyText = await runMock(prompt);
        }

        const token = {
          tokenId: uid("tok"),
          ts: now(),
          type: "AGENT_REPLY",
          agentId: a.id,
          agentName,
          text: replyText,
          hash: sha(replyText),
          scope: "archive"
        };
        appendJsonl(path.join(dir, "archive.jsonl"), token);
        wsSend(ws, { type:"agent_done", agentId: a.id, text: replyText });
      }

      const transcript = buildTranscript(dir);
      fs.writeFileSync(path.join(dir, "transcript.md"), transcript);
      scpDispatch(sessionId);

      wsSend(ws, { type:"job_done" });
      return;
    }

    if (msg.type === "relay_send" || msg.type === "relay_check" || msg.type === "relay_resume") {
      await handleRelayMsg(ws, msg);
      return;
    }

    if (msg.type === "export_now") {
      const sessionId = String(msg.sessionId || "");
      const dir = ensureSessionDirs(sessionId);
      const transcript = buildTranscript(dir);
      fs.writeFileSync(path.join(dir, "transcript.md"), transcript);
      scpDispatch(sessionId);
      wsSend(ws, { type:"export_done" });
      return;
    }
  });
});

// ─────────────────────────────────────────────
// REMOTE RELAY V1.2
// ─────────────────────────────────────────────

const BUNDLE_MAX_BYTES = 200 * 1024 * 1024; // 200 MB

// Active polling intervals: sessionId → {timer, seq, profile, ws}
const relayPolls = new Map();

function loadRelayProfile(profileName) {
  const p = (profileName || process.env.REMOTE_RELAY_PROFILE || "ami1").toUpperCase();
  const host    = process.env[`REMOTE_${p}_HOST`];
  const port    = process.env[`REMOTE_${p}_PORT`]     || "22";
  const user    = process.env[`REMOTE_${p}_USER`];
  const keyPath = process.env[`REMOTE_${p}_KEY_PATH`];
  const inbox   = process.env[`REMOTE_${p}_INBOX`];
  const outbox  = process.env[`REMOTE_${p}_OUTBOX`];
  if (!host || !user || !inbox || !outbox) return null;
  return { host, port, user, keyPath, inbox, outbox };
}

function sshBaseArgs(profile) {
  return ["-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new",
          "-p", profile.port, ...(profile.keyPath ? ["-i", profile.keyPath] : [])];
}

function scpBaseArgs(profile) {
  return ["-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=accept-new",
          "-P", profile.port, ...(profile.keyPath ? ["-i", profile.keyPath] : [])];
}

function spawnPromise(cmd, args, opts = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(cmd, args, { stdio: "ignore", ...opts });
    child.on("close", code => code === 0 ? resolve() : reject(new Error(`${cmd} exited ${code}`)));
    child.on("error", reject);
  });
}

function spawnCapture(cmd, args) {
  return new Promise((resolve) => {
    let out = "";
    const child = spawn(cmd, args, { stdio: ["ignore", "pipe", "ignore"] });
    child.stdout.on("data", d => out += d.toString());
    child.on("close", code => resolve({ code, out }));
    child.on("error", () => resolve({ code: -1, out }));
  });
}

async function createBundle(sessionId, seq) {
  const dir = sessionDir(sessionId);
  const bundleName = `bundle_${sessionId}_${seq}`;
  const archivePath = path.join(dir, `${bundleName}.tar.zst`);
  const readyPath   = path.join(dir, `${bundleName}.ready`);

  const state = readState(sessionId) || {};

  // Write manifest (no secrets — only routing/resume info)
  const manifest = {
    sessionId,
    seq,
    createdAt: now(),
    from: "local",
    expectedReturn: true,
    resume: state.resume || null,
    hash: null
  };
  const manifestPath = path.join(dir, "manifest.json");
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));

  // Collect files to bundle
  const candidates = ["manifest.json", "state.json", "archive.jsonl", "public.jsonl",
                       "transcript.md", "captures", "assets"];
  const files = candidates.filter(f => fs.existsSync(path.join(dir, f)));

  // Create archive
  await spawnPromise("tar", ["--zstd", "-cf", archivePath, "-C", dir, ...files]);

  // Size guard
  const { size } = fs.statSync(archivePath);
  if (size > BUNDLE_MAX_BYTES) {
    fs.unlinkSync(archivePath);
    throw new Error(`BUNDLE_TOO_LARGE: ${size} bytes > ${BUNDLE_MAX_BYTES}`);
  }

  // Hash archive
  const archiveHash = sha(fs.readFileSync(archivePath).toString("base64"));
  manifest.hash = archiveHash;
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
  fs.writeFileSync(readyPath, JSON.stringify({ sessionId, seq, hash: archiveHash }));

  return { archivePath, readyPath, bundleName };
}

async function sendBundleToRemote(profile, dir, bundleName) {
  const ssh = sshBaseArgs(profile);
  const scp = scpBaseArgs(profile);
  const remote = `${profile.user}@${profile.host}`;

  await spawnPromise("ssh", [...ssh, remote, `mkdir -p "${profile.inbox}"`]);
  await spawnPromise("scp", [...scp, path.join(dir, `${bundleName}.tar.zst`), `${remote}:${profile.inbox}/${bundleName}.tar.zst`]);
  await spawnPromise("scp", [...scp, path.join(dir, `${bundleName}.ready`),   `${remote}:${profile.inbox}/${bundleName}.ready`]);
}

async function checkRemoteForReturn(profile, sessionId, seq) {
  const ssh = sshBaseArgs(profile);
  const remote = `${profile.user}@${profile.host}`;
  const readyFile = `return_${sessionId}_${seq}.ready`;

  const { code, out } = await spawnCapture("ssh", [
    ...ssh, remote,
    `test -f "${profile.outbox}/${readyFile}" && cat "${profile.outbox}/${readyFile}" || true`
  ]);

  if (code !== 0 || !out.trim()) return null;
  return safeJson(out.trim()) || {};
}

async function downloadReturnBundle(profile, sessionId, seq, dir) {
  const scp = scpBaseArgs(profile);
  const ssh = sshBaseArgs(profile);
  const remote = `${profile.user}@${profile.host}`;
  const returnName = `return_${sessionId}_${seq}`;
  const localPath = path.join(dir, `${returnName}.tar.zst`);

  await spawnPromise("scp", [...scp, `${remote}:${profile.outbox}/${returnName}.tar.zst`, localPath]);

  // Ack: rename .ready → .ready.ack on remote
  await spawnCapture("ssh", [...ssh, remote,
    `mv "${profile.outbox}/${returnName}.ready" "${profile.outbox}/${returnName}.ready.ack" 2>/dev/null || true`]);

  return localPath;
}

async function importReturnBundle(sessionId, archivePath) {
  const dir = sessionDir(sessionId);
  const seqMatch = path.basename(archivePath).match(/return_[^_]+_(\w+)\.tar\.zst$/);
  const seq = seqMatch ? seqMatch[1] : "0";
  const extractDir = path.join(dir, "remote_inbox", seq);
  fs.mkdirSync(extractDir, { recursive: true });

  await spawnPromise("tar", ["--zstd", "-xf", archivePath, "-C", extractDir]);

  const archiveJsonl = path.join(dir, "archive.jsonl");
  const publicJsonl  = path.join(dir, "public.jsonl");

  function hashExistsIn(file, h) {
    if (!fs.existsSync(file)) return false;
    return fs.readFileSync(file, "utf8").split("\n").filter(Boolean).some(l => {
      try { return JSON.parse(l).hash === h; } catch { return false; }
    });
  }

  // Import reply.md
  const replyPath = path.join(extractDir, "reply.md");
  if (fs.existsSync(replyPath)) {
    const text = fs.readFileSync(replyPath, "utf8");
    const h = sha(text);
    if (!hashExistsIn(archiveJsonl, h)) {
      appendJsonl(archiveJsonl, { tokenId: uid("tok"), ts: now(), type: "TOKEN_REMOTE_REPLY",
        agentId: "remote", text, hash: h, scope: "archive" });
    }
  }

  // Import public_additions.jsonl
  const pubAddPath = path.join(extractDir, "public_additions.jsonl");
  if (fs.existsSync(pubAddPath)) {
    for (const line of fs.readFileSync(pubAddPath, "utf8").split("\n").filter(Boolean)) {
      const obj = safeJson(line);
      if (!obj?.text) continue;
      const h = obj.hash || sha(obj.text);
      if (!hashExistsIn(publicJsonl, h)) {
        appendJsonl(publicJsonl, { ...obj, tokenId: uid("tok"), ts: now(),
          type: "TOKEN_REMOTE_PROOF", hash: h, scope: "public" });
      }
    }
  }

  const manifest = fs.existsSync(path.join(extractDir, "manifest.json"))
    ? safeJson(fs.readFileSync(path.join(extractDir, "manifest.json"), "utf8"))
    : null;

  return { extractDir, manifest };
}

// --- Relay state helpers
function getRelayState(state) {
  return state?.relayState || "LOCAL_RUNNING";
}

function setRelayStateInFile(sessionId, relayState, extra = {}) {
  const state = readState(sessionId) || {};
  state.relayState = relayState;
  Object.assign(state, extra);
  writeState(sessionId, state);
  return state;
}

// --- Polling manager
function startRelayPoll(ws, sessionId, seq, profile) {
  stopRelayPoll(sessionId);
  const seconds = Number(process.env.REMOTE_POLL_SECONDS || 10);

  const check = async () => {
    try {
      const found = await checkRemoteForReturn(profile, sessionId, seq);
      if (!found) return;

      stopRelayPoll(sessionId);
      const dir = sessionDir(sessionId);
      const localPath = await downloadReturnBundle(profile, sessionId, seq, dir);
      const { manifest } = await importReturnBundle(sessionId, localPath);
      setRelayStateInFile(sessionId, "RETURN_READY");

      wsSend(ws, { type: "relay_return_ready", sessionId, seq, resume: manifest?.resume || null });
    } catch (err) {
      wsSend(ws, { type: "relay_error", sessionId, error: err.message });
    }
  };

  const timer = setInterval(check, seconds * 1000);
  relayPolls.set(sessionId, { timer, seq, profile, ws });
}

function stopRelayPoll(sessionId) {
  const entry = relayPolls.get(sessionId);
  if (entry) { clearInterval(entry.timer); relayPolls.delete(sessionId); }
}

// --- WS relay handlers (called from main ws.on("message") handler)
async function handleRelayMsg(ws, msg) {
  const sessionId = String(msg.sessionId || "");
  if (!sessionId) return;

  // relay_send: create bundle + scp + WAITING_REMOTE
  if (msg.type === "relay_send") {
    const profileName = String(msg.profile || process.env.REMOTE_RELAY_PROFILE || "ami1");
    const profile = loadRelayProfile(profileName);
    if (!profile) {
      wsSend(ws, { type: "relay_error", sessionId, error: "PROFILE_NOT_CONFIGURED" });
      return;
    }

    const state = readState(sessionId);
    if (!state) { wsSend(ws, { type: "relay_error", sessionId, error: "SESSION_NOT_FOUND" }); return; }

    const seq = (state.relaySeq || 0) + 1;
    const dir = sessionDir(sessionId);

    try {
      wsSend(ws, { type: "relay_status", sessionId, state: "SENDING", seq });
      const { bundleName } = await createBundle(sessionId, seq);
      await sendBundleToRemote(profile, dir, bundleName);
      setRelayStateInFile(sessionId, "WAITING_REMOTE", { relaySeq: seq, relayProfile: profileName });

      wsSend(ws, { type: "relay_status", sessionId, state: "WAITING_REMOTE", seq });

      if (msg.pollMode !== "MANUAL") {
        startRelayPoll(ws, sessionId, seq, profile);
      }
    } catch (err) {
      wsSend(ws, { type: "relay_error", sessionId, error: err.message });
    }
    return;
  }

  // relay_check: manual poll
  if (msg.type === "relay_check") {
    const state = readState(sessionId);
    if (!state) { wsSend(ws, { type: "relay_error", sessionId, error: "SESSION_NOT_FOUND" }); return; }

    const profileName = state.relayProfile || process.env.REMOTE_RELAY_PROFILE || "ami1";
    const profile = loadRelayProfile(profileName);
    if (!profile) { wsSend(ws, { type: "relay_error", sessionId, error: "PROFILE_NOT_CONFIGURED" }); return; }

    const seq = state.relaySeq || 1;
    try {
      wsSend(ws, { type: "relay_status", sessionId, state: "CHECKING", seq });
      const found = await checkRemoteForReturn(profile, sessionId, seq);
      if (!found) {
        wsSend(ws, { type: "relay_status", sessionId, state: "WAITING_REMOTE", seq, found: false });
        return;
      }
      stopRelayPoll(sessionId);
      const dir = sessionDir(sessionId);
      const localPath = await downloadReturnBundle(profile, sessionId, seq, dir);
      const { manifest } = await importReturnBundle(sessionId, localPath);
      setRelayStateInFile(sessionId, "RETURN_READY");
      wsSend(ws, { type: "relay_return_ready", sessionId, seq, resume: manifest?.resume || null });
    } catch (err) {
      wsSend(ws, { type: "relay_error", sessionId, error: err.message });
    }
    return;
  }

  // relay_resume: mark RESUMED → LOCAL_RUNNING
  if (msg.type === "relay_resume") {
    setRelayStateInFile(sessionId, "LOCAL_RUNNING");
    wsSend(ws, { type: "relay_status", sessionId, state: "LOCAL_RUNNING" });
    return;
  }
}

server.listen(PORT, () => {
  process.stdout.write(`ChromIAlux: http://localhost:${PORT}\n`);
});
