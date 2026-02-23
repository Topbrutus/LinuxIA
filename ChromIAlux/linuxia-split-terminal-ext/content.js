(() => {
  "use strict";

  const WRAPPER_ID  = "linuxia-wrapper";
  const ROW_ID      = "linuxia-row";
  const HOST_ID     = "linuxia-chatgpt-host";
  const IFRAME_ID   = "linuxia-ttyd-iframe";
  const MIRROR_ID   = "linuxia-term-mirror";
  const DEFAULT_URL = "http://127.0.0.1:7681/";

  // ─── Terminal mirror buffer (plain text, stripped ANSI) ─────────────────────
  let mirrorBuf = "";
  const MAX_BUF  = 200_000;
  const RE_ANSI  = /\x1b(?:\[[0-9;?]*[A-Za-z]|\][^\x07]*\x07|[()][A-Z0-9]|[A-Za-z])/g;

  function appendBuffer(raw) {
    if (typeof raw !== "string" || raw.length === 0) return;
    if (raw.charAt(0) !== "1") return;  // only output frames
    let text;
    try { text = atob(raw.slice(1)); } catch { text = raw.slice(1); }
    text = text.replace(RE_ANSI, "").replace(/\r\n/g, "\n").replace(/\r/g, "\n");
    mirrorBuf += text;
    if (mirrorBuf.length > MAX_BUF) mirrorBuf = mirrorBuf.slice(-180_000);
  }

  function renderMirror() {
    const el = document.getElementById(MIRROR_ID);
    if (!el) return;
    el.textContent = mirrorBuf;
    el.scrollTop = el.scrollHeight;
  }

  // ─── Layout helpers ──────────────────────────────────────────────────────────
  function css(el, styles) {
    for (const [k, v] of Object.entries(styles)) el.style[k] = v;
  }

  // ─── Build side-by-side split ────────────────────────────────────────────────
  function ensureDock(url) {
    if (document.getElementById(WRAPPER_ID)) return;
    url = url || DEFAULT_URL;

    // ── Snapshot & evict current body children ──────────────────────────────
    const fragment = document.createDocumentFragment();
    while (document.body.firstChild) fragment.appendChild(document.body.firstChild);

    // ── ChatGPT host (left column) ──────────────────────────────────────────
    const chatHost = document.createElement("div");
    chatHost.id = HOST_ID;
    css(chatHost, { flex: "1", minWidth: "0", overflow: "auto", height: "100%" });
    chatHost.appendChild(fragment);

    // ── Right column: header bar + mirror strip + ttyd iframe ───────────────
    const right = document.createElement("div");
    css(right, {
      display: "flex", flexDirection: "column",
      width: "44vw", minWidth: "320px", maxWidth: "860px",
      borderLeft: "2px solid rgba(78,252,255,0.35)",
      background: "#0b0b0b",
    });

    // header bar
    const bar = document.createElement("div");
    css(bar, {
      height: "30px", flexShrink: "0",
      display: "flex", alignItems: "center", justifyContent: "space-between",
      padding: "0 10px", background: "#111",
      color: "#4efcff", fontSize: "12px", fontWeight: "bold",
      borderBottom: "1px solid #222",
    });
    const title = document.createElement("span");
    title.textContent = "◈ LinuxIA Terminal";
    const closeBtn = document.createElement("button");
    closeBtn.textContent = "✕";
    css(closeBtn, {
      background: "#1a1a1a", border: "1px solid #555", color: "#ccc",
      padding: "2px 8px", cursor: "pointer", borderRadius: "3px", fontSize: "11px",
    });
    bar.appendChild(title);
    bar.appendChild(closeBtn);

    // mirror strip
    const mirror = document.createElement("pre");
    mirror.id = MIRROR_ID;
    css(mirror, {
      height: "14vh", flexShrink: "0", overflow: "auto",
      margin: "0", padding: "6px 8px",
      font: "11px/1.4 \"Consolas\",\"Liberation Mono\",monospace",
      background: "#0b0b0b", color: "#b0b0b0",
      borderBottom: "1px solid #222",
      whiteSpace: "pre-wrap", wordBreak: "break-all",
    });
    mirror.textContent = mirrorBuf;

    // ttyd iframe
    const iframe = document.createElement("iframe");
    iframe.id = IFRAME_ID;
    iframe.src = url;
    iframe.allow = "clipboard-read; clipboard-write";
    css(iframe, { flex: "1", border: "0", width: "100%", minHeight: "0" });

    right.appendChild(bar);
    right.appendChild(mirror);
    right.appendChild(iframe);

    // ── Row ─────────────────────────────────────────────────────────────────
    const row = document.createElement("div");
    row.id = ROW_ID;
    css(row, { display: "flex", flexDirection: "row", flex: "1", overflow: "hidden" });
    row.appendChild(chatHost);
    row.appendChild(right);

    // ── Wrapper ──────────────────────────────────────────────────────────────
    const wrapper = document.createElement("div");
    wrapper.id = WRAPPER_ID;
    css(wrapper, {
      display: "flex", flexDirection: "column",
      width: "100vw", height: "100vh", overflow: "hidden",
    });
    wrapper.appendChild(row);

    // ── Mount ────────────────────────────────────────────────────────────────
    css(document.body, { margin: "0", padding: "0", height: "100vh", overflow: "hidden" });
    document.body.appendChild(wrapper);

    closeBtn.addEventListener("click", removeDock);
  }

  function removeDock() {
    const wrapper = document.getElementById(WRAPPER_ID);
    if (!wrapper) return;
    const host = document.getElementById(HOST_ID);
    const restored = document.createDocumentFragment();
    if (host) { while (host.firstChild) restored.appendChild(host.firstChild); }
    wrapper.remove();
    css(document.body, { margin: "", padding: "", height: "", overflow: "" });
    document.body.prepend(restored);
  }

  // ─── Extension messages ──────────────────────────────────────────────────────
  chrome.runtime.onMessage.addListener((msg) => {
    if (!msg) return;
    if (msg.type === "TERM_OUT") { appendBuffer(msg.data); renderMirror(); }
    if (msg.type === "DOCK_SHOW") ensureDock(msg.url || DEFAULT_URL);
    if (msg.type === "DOCK_HIDE") removeDock();
    if (msg.type === "TERMINAL_BUFFER_UPDATE") {
      const lines = msg.lines || [];
      mirrorBuf = lines.join("\n");
      renderMirror();
    }
  });

  // ─── Init ────────────────────────────────────────────────────────────────────
  chrome.runtime.sendMessage({ type: "REGISTER_CHATGPT_TAB" }).catch(() => {});
  chrome.storage.local.get(["linuxiaDockOn"], (s) => {
    if (s.linuxiaDockOn) ensureDock(DEFAULT_URL);
  });
})();
