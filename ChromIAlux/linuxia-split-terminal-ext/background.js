const STATE = {
  dockOn: false,
  scanOn: false,
};

const BRIDGE = {
  ttydTabId: null,
  chatTabId: null,
};

const TTYD_HTTP = "http://127.0.0.1:7681/";
const TTYD_WS   = "ws://127.0.0.1:7681/ws";

// ─── TerminalWS ───────────────────────────────────────────────────────────────
// Single WebSocket: receives output (broadcasts TERM_OUT) + sends input frames.
const TerminalWS = {
  ws:             null,
  ready:          false,
  connecting:     false,
  reconnectTimer: null,
  inputQueue:     [],

  connect() {
    if (this.connecting || this.ready) return;
    this.connecting = true;
    try {
      const ws = new WebSocket(TTYD_WS);
      this.ws = ws;
      ws.binaryType = "arraybuffer";

      ws.onopen = () => {
        this.connecting = false;
        this.ready = true;
        console.log("[LinuxIA] WS CONNECTED");
        try { ws.send(JSON.stringify({ AuthToken: "" })); } catch (_) {}
        setTimeout(() => this._flushQueue(), 120);
      };

      ws.onmessage = (evt) => {
        let data;
        if (evt.data instanceof ArrayBuffer) {
          const bytes = new Uint8Array(evt.data);
          if (bytes.length === 0) return;
          data = String.fromCharCode(bytes[0]) + new TextDecoder().decode(bytes.slice(1));
        } else {
          data = String(evt.data);
        }
        console.log("[LinuxIA] WS MESSAGE", data.slice(0, 80));
        broadcastTermOut(data);
      };

      ws.onclose = () => {
        if (this.ws !== ws) return;
        this.ready = false;
        this.connecting = false;
        this.ws = null;
        console.log("[LinuxIA] WS CLOSED");
        if (STATE.dockOn) this._scheduleReconnect();
      };

      ws.onerror = () => {
        if (this.ws !== ws) return;
        this.ready = false;
        this.connecting = false;
        this.ws = null;
        if (STATE.dockOn) this._scheduleReconnect();
      };
    } catch (_) {
      this.connecting = false;
      this.ready = false;
      this.ws = null;
      if (STATE.dockOn) this._scheduleReconnect();
    }
  },

  _scheduleReconnect() {
    if (this.reconnectTimer) return;
    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = null;
      this.connect();
    }, 2000);
  },

  disconnect() {
    if (this.reconnectTimer) { clearTimeout(this.reconnectTimer); this.reconnectTimer = null; }
    try { if (this.ws) this.ws.close(); } catch (_) {}
    this.ws = null;
    this.ready = false;
    this.connecting = false;
  },

  sendInput(text) {
    const payload = "0" + String(text || "") + "\r";
    if (!this.ready || !this.ws) {
      this.inputQueue.push(payload);
      this.connect();
      return;
    }
    try { this.ws.send(payload); } catch (_) {
      this.ready = false;
      this.ws = null;
      this.inputQueue.push(payload);
      this.connect();
    }
  },

  _flushQueue() {
    if (!this.ready || !this.ws) return;
    for (const p of this.inputQueue.splice(0)) {
      try { this.ws.send(p); } catch (_) {}
    }
  },
};

function broadcastTermOut(data) {
  chrome.tabs.query({}, (tabs) => {
    for (const tab of tabs) {
      if (!tab.id) continue;
      chrome.tabs.sendMessage(tab.id, { type: "TERM_OUT", data }).catch(() => {});
    }
  });
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
function setBadge() {
  const text = STATE.dockOn ? (STATE.scanOn ? "SCAN" : "ON") : "";
  chrome.action.setBadgeText({ text });
}

async function getActiveTabId() {
  const [tab] = await chrome.tabs.query({ active: true, lastFocusedWindow: true });
  return tab?.id;
}

async function sendToActiveTab(msg) {
  const tabId = await getActiveTabId();
  if (!tabId) return;
  try {
    await chrome.tabs.sendMessage(tabId, msg);
  } catch {
    setTimeout(() => chrome.tabs.sendMessage(tabId, msg).catch(() => {}), 250);
  }
}

function ensureContextMenu() {
  chrome.contextMenus.removeAll(() => {
    chrome.contextMenus.create({
      id: "linuxia_send_selection",
      title: "→ LinuxIA Terminal (dock)",
      contexts: ["selection"],
    });
  });
}

function sendToTerminal(text) {
  const t = String(text || "").trim();
  if (!t) return;
  TerminalWS.sendInput(t);
}

// ─── Dock toggle ──────────────────────────────────────────────────────────────
async function toggleDock(force) {
  STATE.dockOn = typeof force === "boolean" ? force : !STATE.dockOn;
  await chrome.storage.local.set({ linuxiaDockOn: STATE.dockOn });
  setBadge();
  if (STATE.dockOn) {
    TerminalWS.connect();
    await sendToActiveTab({ type: "DOCK_SHOW", url: TTYD_HTTP });
  } else {
    await sendToActiveTab({ type: "DOCK_HIDE" });
  }
}

async function toggleScan(force) {
  STATE.scanOn = typeof force === "boolean" ? force : !STATE.scanOn;
  await chrome.storage.local.set({ linuxiaScanOn: STATE.scanOn });
  setBadge();
}

// ─── Lifecycle ────────────────────────────────────────────────────────────────
chrome.runtime.onInstalled.addListener(async () => {
  const stored = await chrome.storage.local.get(["linuxiaDockOn", "linuxiaScanOn"]);
  STATE.dockOn = !!stored.linuxiaDockOn;
  STATE.scanOn = !!stored.linuxiaScanOn;
  setBadge();
  ensureContextMenu();
  if (STATE.dockOn) TerminalWS.connect();
});

chrome.runtime.onStartup.addListener(async () => {
  const stored = await chrome.storage.local.get(["linuxiaDockOn", "linuxiaScanOn"]);
  STATE.dockOn = !!stored.linuxiaDockOn;
  STATE.scanOn = !!stored.linuxiaScanOn;
  setBadge();
  ensureContextMenu();
  if (STATE.dockOn) TerminalWS.connect();
});

chrome.action.onClicked.addListener(async () => {
  await toggleDock();
});

chrome.commands.onCommand.addListener(async (cmd) => {
  if (cmd === "toggle-dock") await toggleDock();
  if (cmd === "toggle-scan") await toggleScan();
});

chrome.contextMenus.onClicked.addListener(async (info) => {
  if (info.menuItemId === "linuxia_send_selection") {
    const text = (info.selectionText || "").trim();
    if (text) sendToTerminal(text);
  }
});

// ─── Message relay ────────────────────────────────────────────────────────────
chrome.runtime.onMessage.addListener((msg, sender) => {
  if (!msg || typeof msg !== "object") return;

  if (msg.type === "SCAN_TEXT") {
    if (!STATE.scanOn) return;
    if (!STATE.dockOn) toggleDock(true);
    sendToTerminal(msg.text);
  }

  if (msg.type === "TERMINAL_BUFFER") {
    if (sender.tab) BRIDGE.ttydTabId = sender.tab.id;
    if (BRIDGE.chatTabId) {
      chrome.tabs.sendMessage(BRIDGE.chatTabId, {
        type: "TERMINAL_BUFFER_UPDATE",
        lines: msg.lines || [],
        content: msg.content || "",
      }).catch(() => {});
    }
  }

  if (msg.type === "SEND_TO_TERMINAL_REQ") {
    if (sender.tab) BRIDGE.chatTabId = sender.tab.id;
    const text = String(msg.text || "").trim();
    if (!text) return;
    if (BRIDGE.ttydTabId) {
      chrome.tabs.sendMessage(BRIDGE.ttydTabId, { type: "SEND_TO_TERMINAL", text }).catch(() => {
        sendToTerminal(text);
      });
    } else {
      sendToTerminal(text);
    }
  }

  if (msg.type === "REGISTER_CHATGPT_TAB") {
    if (sender.tab) BRIDGE.chatTabId = sender.tab.id;
  }
});

chrome.tabs.onUpdated.addListener((tabId, _info, tab) => {
  if (tab.url && tab.url.startsWith("http://127.0.0.1:7681")) {
    BRIDGE.ttydTabId = tabId;
  }
});
