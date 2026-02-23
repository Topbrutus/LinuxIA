import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Dict

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import HTMLResponse, FileResponse, PlainTextResponse

APP_NAME = "LinuxIA WOW"
BASE = Path("/opt/linuxia/mailbox")
INBOX = BASE / "inbox"
OUTBOX = BASE / "outbox"
LEDGER = BASE / "ledger"
SCAN_LINES = 200

def ensure_dirs() -> None:
    for p in (INBOX, OUTBOX, LEDGER):
        p.mkdir(parents=True, exist_ok=True)

def list_inbox() -> List[Dict]:
    if not INBOX.exists():
        return []
    items = []
    for f in sorted(INBOX.iterdir(), key=lambda x: x.stat().st_mtime, reverse=True):
        if f.is_file():
            st = f.stat()
            items.append({"name": f.name, "size": st.st_size, "mtime": datetime.fromtimestamp(st.st_mtime).isoformat()})
    return items

def list_jobs() -> List[Dict]:
    if not OUTBOX.exists():
        return []
    jobs = []
    for d in sorted(OUTBOX.iterdir(), key=lambda x: x.stat().st_mtime, reverse=True):
        if d.is_dir() and d.name.startswith("job_"):
            st = d.stat()
            jobs.append({"id": d.name, "mtime": datetime.fromtimestamp(st.st_mtime).isoformat()})
    return jobs

def ledger_tail(n: int = 50) -> List[str]:
    ev = LEDGER / "events.jsonl"
    if not ev.exists():
        return []
    lines = ev.read_text(errors="replace").splitlines()
    return lines[-n:]

def run(cmd: List[str], timeout: int = 5) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=timeout)

def scan_text() -> str:
    # 1) tmux capture-pane
    try:
        p = run(["tmux", "capture-pane", "-pS", f"-{SCAN_LINES}"], timeout=2)
        if p.returncode == 0 and p.stdout.strip():
            return p.stdout
    except Exception:
        pass

    # 2) journalctl fallback
    try:
        p = run(["journalctl", "-n", str(SCAN_LINES), "--no-pager"], timeout=4)
        if p.returncode == 0 and p.stdout.strip():
            return p.stdout
    except Exception:
        pass

    return "SCAN: aucune source disponible (tmux/journalctl)."

def write_scan() -> Dict:
    ensure_dirs()
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    fname = f"terminal_scan_{ts}.txt"
    target = INBOX / fname
    content = scan_text()
    target.write_text(content, encoding="utf-8", errors="replace")
    return {"written": str(target), "bytes": target.stat().st_size}

def save_upload(up: UploadFile) -> Dict:
    ensure_dirs()
    name = Path(up.filename).name
    if not name:
        raise HTTPException(400, "Nom de fichier invalide.")
    target = INBOX / name
    if target.exists():
        stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
        target = INBOX / f"{stamp}__{name}"
    with target.open("wb") as f:
        shutil.copyfileobj(up.file, f)
    return {"saved_as": str(target), "bytes": target.stat().st_size}

UI_TEMPLATE = """<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8"/><meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>__APP_NAME__</title>
<style>
body{font-family:system-ui,sans-serif;margin:0;background:#0b0f14;color:#e8eef6}
header{padding:12px 16px;border-bottom:1px solid #223;display:flex;gap:12px;align-items:center}
.btn{background:#1f2937;color:#e8eef6;border:1px solid #334155;padding:8px 10px;border-radius:10px;cursor:pointer}
.btn:hover{filter:brightness(1.1)}
.wrap{display:grid;grid-template-rows:1fr 1fr;gap:10px;padding:10px;height:calc(100vh - 54px)}
.panel{border:1px solid #223;border-radius:14px;overflow:hidden;background:#0f1620}
.panel h3{margin:0;padding:10px 12px;border-bottom:1px solid #223;font-size:14px;display:flex;justify-content:space-between}
.content{padding:10px 12px}
.cols{display:grid;grid-template-columns:1.2fr 1fr;gap:10px}
.drop{border:2px dashed #334155;border-radius:14px;padding:14px;text-align:center}
.muted{color:#9aa6b2;font-size:12px}
iframe{width:100%;height:100%;border:0;background:#000}
pre{background:#0b1220;padding:10px;border-radius:12px;overflow:auto;border:1px solid #223}
a{color:#93c5fd;text-decoration:none} a:hover{text-decoration:underline}
</style>
</head>
<body>
<header>
  <b>🧠 __APP_NAME__</b>
  <button class="btn" onclick="doScan()">🟦 SCAN → Inbox</button>
  <button class="btn" onclick="refreshAll()">🔄 Refresh</button>
  <span class="muted">Local-only: 127.0.0.1</span>
</header>

<div class="wrap">
  <div class="panel">
    <h3>💬 Zone Centrale (Drag&Drop + Jobs + Ledger) <span class="muted">phase UI</span></h3>
    <div class="content cols">
      <div>
        <div class="drop" id="drop">
          <div><b>📥 Drag & Drop ici → Inbox</b></div>
          <div class="muted">ou clique: <input type="file" id="fileInput"/></div>
          <div class="muted" id="status"></div>
        </div>

        <h4>📦 Inbox</h4>
        <ul id="inbox"></ul>

        <h4>🧾 Ledger (tail)</h4>
        <pre id="ledger" class="muted">…</pre>
      </div>

      <div>
        <h4>📤 Outbox (jobs)</h4>
        <ul id="jobs"></ul>
        <div class="muted">Clique un job pour voir sa liste de fichiers.</div>
      </div>
    </div>
  </div>

  <div class="panel">
    <h3>🖥️ Terminal Web (ttyd) <span class="muted">127.0.0.1:7681</span></h3>
    <iframe src="http://127.0.0.1:7681/"></iframe>
  </div>
</div>

<script>
const drop=document.getElementById('drop');
const fileInput=document.getElementById('fileInput');
const status=document.getElementById('status');

drop.addEventListener('dragover',e=>{e.preventDefault();drop.style.filter='brightness(1.15)';});
drop.addEventListener('dragleave',e=>{e.preventDefault();drop.style.filter='';});
drop.addEventListener('drop',async e=>{
  e.preventDefault();drop.style.filter='';
  if(!e.dataTransfer.files||e.dataTransfer.files.length===0)return;
  await uploadFile(e.dataTransfer.files[0]);
});
fileInput.addEventListener('change',async()=>{
  if(!fileInput.files||fileInput.files.length===0)return;
  await uploadFile(fileInput.files[0]);
});

async function uploadFile(file){
  status.textContent=`Upload: ${file.name} …`;
  const fd=new FormData(); fd.append('file',file);
  const r=await fetch('/api/upload',{method:'POST',body:fd});
  const j=await r.json();
  status.textContent=r.ok?`✅ Inbox: ${j.saved_as} (${j.bytes} bytes)`: `❌ ${j.detail||'Erreur'}`;
  await refreshAll();
}

async function doScan(){
  const r=await fetch('/api/scan',{method:'POST'});
  const j=await r.json();
  status.textContent=r.ok?`✅ SCAN écrit: ${j.written} (${j.bytes} bytes)`: `❌ ${j.detail||'Erreur'}`;
  await refreshAll();
}

async function refreshAll(){
  const [inb,jobs,led]=await Promise.all([
    fetch('/api/inbox').then(r=>r.json()),
    fetch('/api/jobs').then(r=>r.json()),
    fetch('/api/ledger_tail?n=50').then(r=>r.json())
  ]);

  const inbox=document.getElementById('inbox'); inbox.innerHTML='';
  (inb.items||[]).slice(0,12).forEach(x=>{
    const li=document.createElement('li');
    li.textContent=`${x.name} (${x.size} bytes)`;
    inbox.appendChild(li);
  });

  const jl=document.getElementById('jobs'); jl.innerHTML='';
  (jobs.jobs||[]).slice(0,30).forEach(x=>{
    const li=document.createElement('li');
    const a=document.createElement('a');
    a.href=`/api/job/${encodeURIComponent(x.id)}/list`;
    a.textContent=x.id;
    li.appendChild(a);
    jl.appendChild(li);
  });

  document.getElementById('ledger').textContent=(led.lines||[]).join('\\n')||'—';
}
refreshAll();
</script>
</body>
</html>
"""

def render_ui() -> str:
    return UI_TEMPLATE.replace("__APP_NAME__", APP_NAME)

app = FastAPI(title=APP_NAME)

@app.get("/", response_class=HTMLResponse)
def home():
    ensure_dirs()
    return render_ui()

@app.get("/api/inbox")
def api_inbox():
    return {"items": list_inbox()}

@app.post("/api/upload")
async def api_upload(file: UploadFile = File(...)):
    return save_upload(file)

@app.post("/api/scan")
def api_scan():
    return write_scan()

@app.get("/api/jobs")
def api_jobs():
    return {"jobs": list_jobs()}

@app.get("/api/ledger_tail")
def api_ledger_tail(n: int = 50):
    n = max(1, min(500, n))
    return {"lines": ledger_tail(n)}

@app.get("/api/job/{job_id}/list", response_class=PlainTextResponse)
def api_job_list(job_id: str):
    d = OUTBOX / job_id
    if not d.exists() or not d.is_dir():
        raise HTTPException(404, "Job introuvable.")
    files = []
    for p in sorted(d.rglob("*")):
        if p.is_file():
            files.append(str(p.relative_to(d)))
    return "\n".join(files) if files else "(job vide)"

@app.get("/api/job/{job_id}/file/{rel_path:path}")
def api_job_file(job_id: str, rel_path: str):
    d = OUTBOX / job_id
    p = (d / rel_path).resolve()
    if not str(p).startswith(str(d.resolve())):
        raise HTTPException(400, "Chemin invalide.")
    if not p.exists() or not p.is_file():
        raise HTTPException(404, "Fichier introuvable.")
    return FileResponse(str(p))
