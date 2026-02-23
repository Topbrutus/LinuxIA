// bridge.js — content script injecté dans http://127.0.0.1:7681/*
// Lit le buffer xterm, relaie vers background, reçoit les commandes.

(() => {
  const POLL_MS = 600;
  let lastSent = "";
  let hooked = false;

  function getXterm() {
    if (window.term && window.term.buffer) return window.term;
    const el = document.querySelector(".xterm");
    if (el) {
      for (const key of Object.keys(el)) {
        if (key.startsWith("_") && el[key] && el[key].buffer) return el[key];
      }
    }
    return null;
  }

  function readBuffer(term) {
    try {
      const buf = term.buffer.active;
      const lines = [];
      for (let i = 0; i < buf.length; i++) {
        const line = buf.getLine(i);
        if (line) lines.push(line.translateToString(true));
      }
      while (lines.length && !lines[lines.length - 1].trim()) lines.pop();
      return lines;
    } catch { return []; }
  }

  function poll() {
    const term = getXterm();
    if (!term) return;
    const lines = readBuffer(term);
    const content = lines.join("\n");
    if (content === lastSent) return;
    lastSent = content;
    chrome.runtime.sendMessage({
      type: "TERMINAL_BUFFER",
      content,
      lines: lines.slice(-60),
    }).catch(() => {});
  }

  function hookXterm() {
    if (hooked) return;
    const term = getXterm();
    if (!term) { setTimeout(hookXterm, 1000); return; }
    hooked = true;
    try {
      term.onRender(() => {
        clearTimeout(window._linuxia_bridge_debounce);
        window._linuxia_bridge_debounce = setTimeout(poll, 180);
      });
    } catch {}
    poll();
  }

  setInterval(poll, POLL_MS);
  hookXterm();

  // Recevoir une commande depuis background
  chrome.runtime.onMessage.addListener((msg) => {
    if (!msg || msg.type !== "SEND_TO_TERMINAL") return;
    const term = getXterm();
    if (!term) return;
    const text = String(msg.text || "").trim();
    if (!text) return;
    try {
      // ttyd: term.input() envoie des frappes clavier brutes
      if (typeof term.input === "function") {
        term.input(text + "\r", true);
      } else if (typeof term.paste === "function") {
        term.paste(text + "\r");
      }
    } catch { /* best effort */ }
  });
})();
