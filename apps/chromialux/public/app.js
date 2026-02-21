const ws = new WebSocket(`ws://${location.host}/ws`);

const $grid = document.getElementById("grid");
const $prompt = document.getElementById("prompt");
const $sessionTag = document.getElementById("sessionTag");
const $dlg = document.getElementById("dlg");
const $sessionList = document.getElementById("sessionList");

let sessionId = null;
let lastSessions = [];

const agents = [];
let autosaveTimer = null;

function uid(){ return `a_${Math.random().toString(16).slice(2)}_${Date.now()}`; }
function esc(s){ return String(s).replace(/[&<>"']/g,m=>({ "&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;" }[m])); }

function setSession(id){
  sessionId = id;
  $sessionTag.textContent = sessionId ? `session: ${sessionId}` : "";
  if (autosaveTimer) clearInterval(autosaveTimer);
  autosaveTimer = setInterval(saveSession, 10_000);
}

function newAgent(){
  if (agents.length >= 9) return;
  agents.push({
    id: uid(),
    name: `Agent ${agents.length+1}`,
    kind: "mock",
    rx: true,
    tts: true,
    macro: false,
    rxCountdown: 3,
    roi: { x1:0.05, y1:0.12, x2:0.95, y2:0.88 },
    avatarDataUrl: null,
    log: ""
  });
  render();
}

function render(){
  $grid.innerHTML = "";
  for (const a of agents){
    const card = document.createElement("div");
    card.className = "card";
    card.dataset.agentId = a.id;

    const head = document.createElement("div");
    head.className = "head";

    const left = document.createElement("div");
    left.innerHTML = `<div class="name">${esc(a.name)}</div><div class="small">${esc(a.kind)} • id:${esc(a.id.slice(0,8))}</div>`;

    const avatar = document.createElement("div");
    avatar.className = "avatar";
    avatar.innerHTML = a.avatarDataUrl ? `<img src="${a.avatarDataUrl}"/>` : "🧠";

    head.append(left, avatar);

    const row = document.createElement("div");
    row.className = "row";

    row.append(pillCheck("RX", a.rx, v=>{ a.rx=v; render(); }));
    row.append(pillCheck("MACRO", a.macro, v=>{ a.macro=v; render(); }));
    row.append(pillNum("RX#", a.rxCountdown, v=>{ a.rxCountdown=v; }));

    const btnAvatar = document.createElement("button");
    btnAvatar.textContent = "🖼️ Avatar";
    btnAvatar.onclick = async ()=>{
      const f = await pickImage();
      if (!f) return;
      a.avatarDataUrl = await fileToDataUrl(f);
      render();
      saveSession();
    };

    const btnROI = document.createElement("button");
    btnROI.textContent = "ROI reset";
    btnROI.onclick = ()=>{
      a.roi = { x1:0.05, y1:0.12, x2:0.95, y2:0.88 };
      saveSession();
    };

    const log = document.createElement("div");
    log.className = "log";
    log.textContent = a.log || "";

    card.append(head, row, btnAvatar, btnROI, log);
    $grid.append(card);
  }
}

function pillCheck(label, val, onChange){
  const wrap = document.createElement("div");
  wrap.className = "pill";
  const cb = document.createElement("input");
  cb.type = "checkbox";
  cb.checked = !!val;
  cb.onchange = ()=> onChange(cb.checked);
  wrap.append(cb, document.createTextNode(label));
  return wrap;
}

function pillNum(label, val, onChange){
  const wrap = document.createElement("div");
  wrap.className = "pill";
  const t = document.createElement("span");
  t.textContent = label;
  const inp = document.createElement("input");
  inp.type = "number";
  inp.min = "0";
  inp.value = String(val ?? 0);
  inp.onchange = ()=> onChange(Math.max(0, Number(inp.value || 0)));
  wrap.append(t, inp);
  return wrap;
}

async function pickImage(){
  return new Promise((resolve)=>{
    const i = document.createElement("input");
    i.type="file"; i.accept="image/*";
    i.onchange = ()=> resolve(i.files?.[0] || null);
    i.click();
  });
}

async function fileToDataUrl(file){
  return new Promise((resolve,reject)=>{
    const r = new FileReader();
    r.onload = ()=> resolve(r.result);
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

function getState(){
  return { sessionId, agents };
}

function applyState(state){
  agents.length = 0;
  for (const a of (state?.agents || [])) agents.push(a);
  render();
}

function saveSession(){
  if (!sessionId) return;
  ws.send(JSON.stringify({ type:"session_save", sessionId, state: getState() }));
}

function sendPrompt(){
  if (!sessionId) return;
  const text = $prompt.value.trim();
  if (!text) return;

  for (const a of agents){
    if (a.rx && a.rxCountdown > 0) a.rxCountdown -= 1;
  }
  render();
  saveSession();

  ws.send(JSON.stringify({
    type:"send_prompt",
    sessionId,
    text,
    agents: agents.map(a => ({
      id: a.id, name: a.name, kind: a.kind,
      rx: a.rx, macro: a.macro,
      rxCountdown: a.rxCountdown,
      roi: a.roi
    }))
  }));
}

document.getElementById("send").onclick = sendPrompt;
$prompt.addEventListener("keydown", (e)=>{ if(e.key==="Enter" && !e.shiftKey){ e.preventDefault(); sendPrompt(); }});

document.getElementById("addAgent").onclick = ()=>{ newAgent(); saveSession(); };
document.getElementById("newSession").onclick = ()=> ws.send(JSON.stringify({ type:"session_new" }));
document.getElementById("resumeSession").onclick = ()=>{
  $sessionList.innerHTML = lastSessions.map(s=>`<option value="${s}">${s}</option>`).join("");
  $dlg.showModal();
};
document.getElementById("saveSession").onclick = saveSession;
document.getElementById("exportNow").onclick = ()=> ws.send(JSON.stringify({ type:"export_now", sessionId }));
document.getElementById("closeDlg").onclick = ()=> $dlg.close();
document.getElementById("loadSel").onclick = ()=>{
  const s = $sessionList.value;
  if (s) ws.send(JSON.stringify({ type:"session_load", sessionId: s }));
  $dlg.close();
};

ws.onmessage = async (ev)=>{
  const msg = JSON.parse(ev.data);

  if (msg.type === "hello"){
    lastSessions = msg.sessions || [];
    return;
  }

  if (msg.type === "session_ready"){
    setSession(msg.sessionId);
    applyState(msg.state || {});
    if (!agents.length){ newAgent(); newAgent(); saveSession(); }
    return;
  }

  if (msg.type === "agent_started"){
    const a = agents.find(x=>x.id===msg.agentId);
    if (a) { a.log = "…"; render(); }
    return;
  }

  if (msg.type === "agent_done"){
    const a = agents.find(x=>x.id===msg.agentId);
    if (a) { a.log = msg.text; render(); saveSession(); }
    return;
  }

  if (msg.type === "capture_request"){
    const a = agents.find(x=>x.id===msg.agentId);
    const el = document.querySelector(`.card[data-agent-id="${msg.agentId}"]`);
    if (!a || !el) return;

    const roi = a.roi || {x1:0, y1:0, x2:1, y2:1};
    const dataUrl = await captureElementROI(el, roi);
    ws.send(JSON.stringify({
      type:"capture_result",
      sessionId: msg.sessionId,
      tokenId: msg.tokenId,
      agentId: msg.agentId,
      label: msg.label || "cap",
      dataUrl
    }));
    return;
  }
};

async function captureElementROI(el, roi){
  const rect = el.getBoundingClientRect();
  const w = Math.max(1, Math.floor(rect.width));
  const h = Math.max(1, Math.floor(rect.height));

  const x1 = Math.floor(w * roi.x1), y1 = Math.floor(h * roi.y1);
  const x2 = Math.floor(w * roi.x2), y2 = Math.floor(h * roi.y2);
  const cw = Math.max(1, x2 - x1), ch = Math.max(1, y2 - y1);

  const clone = el.cloneNode(true);
  clone.style.width = `${w}px`;
  clone.style.height = `${h}px`;

  const svg = `
  <svg xmlns="http://www.w3.org/2000/svg" width="${cw}" height="${ch}">
    <foreignObject x="${-x1}" y="${-y1}" width="${w}" height="${h}">
      ${new XMLSerializer().serializeToString(clone)}
    </foreignObject>
  </svg>`;

  const img = new Image();
  img.src = "data:image/svg+xml;charset=utf-8," + encodeURIComponent(svg);
  await new Promise((res, rej)=>{ img.onload=res; img.onerror=rej; });

  const canvas = document.createElement("canvas");
  canvas.width = cw; canvas.height = ch;
  const ctx = canvas.getContext("2d");
  ctx.drawImage(img, 0, 0);

  return canvas.toDataURL("image/png");
}

ws.onopen = ()=> ws.send(JSON.stringify({ type:"session_new" }));
