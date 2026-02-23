(() => {
  "use strict";

  const DOCK_ID   = "linuxia-ttyd-dock";
  const IFRAME_ID = "linuxia-ttyd-iframe";
  const MIRROR_ID = "linuxia-term-mirror";
  const DEFAULT_URL = "http://127.0.0.1:7681/";

  // ─── Mirror buffer ──────────────────────────────────────────────────────────
  let mirrorBuf = "";
  const MAX_BUF = 200000; // ~200 KB

  // Strip common ANSI/VT100 sequences to get readable text
  const RE_ANSI = /\x1b(?:\[[0-9;?]*[A-Za-z]|\][^\x07]*\x07|[()][A-Z0-9]|[A-Za-z])/g;

  function appendBuffer(raw) {
    if (typeof raw !== "string" || raw.length === 0) return;
    const type = raw.charAt(0);
    if (type !== "1") return; // only output frames; skip AuthToken JSON etc.
    let text;
    try { text = atob(raw.slice(1)); } catch (_) { text = raw.slice(1); }
    text = text.replace(RE_ANSI, "")
               .replace(/\r\n/g, "\n")
               .replace(/\r/g, "\n");
    mirrorBuf += text;
    if (mirrorBuf.length > MAX_BUF) mirrorBuf = mirrorBuf.slice(-180000);
  }

  function renderMirror() {
    const pre = document.getElementById(MIRROR_ID);
    if (!pre) return;
    pre.textContent = mirrorBuf;
    pre.scrollTop = pre.scrollHeight;
  }

  // ─── Dock (position:fixed overlay – NO DOM rewrap) ──────────────────────────
  function ensureDock(url) {
    if (document.getElementById(DOCK_ID)) return;
    url = url || DEFAULT_URL;

    // Wrapper
    const dock = document.createElement("div");
    dock.id = DOCK_ID;
    dock.style.cssText = [
      "position:fixed", "bottom:0", "left:0", "right:0",
      "height:42vh", "z-index:2147483647",
      "display:flex", "flex-direction:column",
      "background:#0b0b0b",
      "border-top:2px solid rgba(78,252,255,0.4)",
      "box-shadow:0 -4px 24px rgba(0,0,0,0.8)",
      "font-family:\"Consolas\",\"Liberation Mono\",monospace",
    ].join(";");

    // Header bar
    const bar = document.createElement("div");
    bar.style.cssText = [
      "height:32px", "flex-shrink:0",
      "display:flex", "align-items:center", "justify-content:space-between",
      "padding:0 10px", "background:#111",
      "color:#4efcff", "font-size:12px", "font-weight:bold",
      "border-bottom:1px solid #222",
    ].join(";");
    const title = document.createElement("span");
    title.textContent = "◈ LinuxIA Terminal";
    const closeBtn = document.createElement("button");
    closeBtn.id = "linuxia-close";
    closeBtn.textContent = "✕ Close";
    closeBtn.style.cssText = [
      "background:#1a1a1a", "border:1px solid #555", "color:#ccc",
      "padding:3px 10px", "cursor:pointer", "border-radius:3px", "font-size:11px",
    ].join(";");
    bar.appendChild(title);
    bar.appendChild(closeBtn);

    // Mirror panel
    const mirror = document.createElement("pre");
    mirror.id = MIRROR_ID;
    mirror.style.cssText = [
      "height:18vh", "flex-shrink:0", "overflow:auto",
      "margin:0", "padding:8px",
      "font:12px/1.4 \"Consolas\",\"Liberation Mono\",monospace",
      "background:#0b0b0b", "color:#d7d7d7",
      "border-bottom:1px solid #333",
      "white-space:pre-wrap", "word-break:break-all",
    ].join(";");
    mirror.textContent = mirrorBuf;

    // iframe (interactive ttyd)
    const iframe = document.createElement("iframe");
    iframe.id = IFRAME_ID;
    iframe.src = url;
    iframe.allow = "clipboard-read; clipboard-write";
    iframe.style.cssText = "flex:1;border:0;width:100%;min-height:0;";

    dock.appendChild(bar);
    dock.appendChild(mirror);   // mirror above iframe
    dock.appendChild(iframe);
    document.body.appendChild(dock);

    // Push page content up so it's not hidden under the overlay
    document.body.style.paddingBottom = "42vh";

    closeBtn.addEventListener("click", removeDock);
  }

  function removeDock() {
    const dock = document.getElementById(DOCK_ID);
    if (dock) dock.remove();
    document.body.style.paddingBottom = "";
  }

  // ─── Message listener ───────────────────────────────────────────────────────
  chrome.runtime.onMessage.addListener((msg) => {
    if (!msg) return;
    if (msg.type === "TERM_OUT") {
      appendBuffer(msg.data);
      renderMirror();
    }
    if (msg.type === "DOCK_SHOW") ensureDock(msg.url || DEFAULT_URL);
    if (msg.type === "DOCK_HIDE") removeDock();
  });

  // ─── Init ───────────────────────────────────────────────────────────────────
  chrome.runtime.sendMessage({ type: "REGISTER_CHATGPT_TAB" }).catch(() => {});

  // Restore dock state on page load (no reload needed)
  chrome.storage.local.get(["linuxiaDockOn"], (s) => {
    if (s.linuxiaDockOn) ensureDock(DEFAULT_URL);
  });
})();
