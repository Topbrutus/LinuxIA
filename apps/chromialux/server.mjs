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

server.listen(PORT, () => {
  process.stdout.write(`ChromIAlux: http://localhost:${PORT}\n`);
});
