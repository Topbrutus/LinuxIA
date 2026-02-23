const DEFAULTS = { termUrl: "http://127.0.0.1:7681/", ratio: 0.62, gap: 6 };
let state = {
  enabled: false,
  parentId: null,
  termId: null,
  origBounds: null,
  lastWarn: null,
  adjusting: false
};

function isChatGPT(url) {
  return (url || "").startsWith("https://chatgpt.com/") || (url || "").startsWith("https://chat.openai.com/");
}

async function getActiveTab() {
  const tabs = await chrome.tabs.query({ active: true, currentWindow: true });
  return tabs && tabs[0];
}

async function getCfg() {
  const cfg = await chrome.storage.local.get(DEFAULTS);
  return { ...DEFAULTS, ...cfg };
}

async function sendToContent(msg) {
  try {
    const tab = await getActiveTab();
    if (tab && tab.id) chrome.tabs.sendMessage(tab.id, msg);
  } catch (_) {}
}

async function toggle() {
  const tab = await getActiveTab();
  if (!tab || !isChatGPT(tab.url)) {
    return { ok: false, enabled: state.enabled, warn: "Ouvre chatgpt.com puis clique Toggle." };
  }
  if (state.enabled) {
    await disableDock();
    return { ok: true, enabled: false };
  } else {
    const r = await enableDock(tab.windowId);
    return { ok: r.ok, enabled: state.enabled, warn: r.warn || null };
  }
}

async function enableDock(windowId) {
  const cfg = await getCfg();
  const parent = await chrome.windows.get(windowId);
  const orig = { left: parent.left, top: parent.top, width: parent.width, height: parent.height };

  const gap = Math.round(cfg.gap);
  const parentH = Math.max(320, Math.floor(orig.height * cfg.ratio));
  const termH = Math.max(220, orig.height - parentH - gap);

  state.adjusting = true;
  await chrome.windows.update(windowId, { left: orig.left, top: orig.top, width: orig.width, height: parentH, focused: true });
  const termWin = await chrome.windows.create({
    url: cfg.termUrl,
    type: "popup",
    left: orig.left,
    top: orig.top + parentH + gap,
    width: orig.width,
    height: termH,
    focused: true
  });

  state.enabled = true;
  state.parentId = windowId;
  state.termId = termWin.id;
  state.origBounds = orig;
  state.adjusting = false;

  try {
    const p2 = await chrome.windows.get(state.parentId);
    const t2 = await chrome.windows.get(state.termId);
    const wantTop = (p2.top ?? orig.top) + (p2.height ?? parentH) + gap;
    const delta = Math.abs((t2.top ?? wantTop) - wantTop) + Math.abs((t2.left ?? orig.left) - (p2.left ?? orig.left));
    if (delta > 60) {
      const warn = "Dock partiel: ton environnement (souvent Wayland) peut ignorer le placement. Si c'est croche: lance Chrome en X11 (voir message).";
      state.lastWarn = warn;
      await sendToContent({ type: "warn", message: warn + " Tip: chrome://flags → Ozone platform hint = X11, puis restart Chrome." });
      return { ok: true, warn };
    }
  } catch (_) {}

  await sendToContent({ type: "state", enabled: true });
  return { ok: true };
}

async function disableDock() {
  if (!state.enabled) return;
  state.adjusting = true;

  const parentId = state.parentId;
  const termId = state.termId;
  const orig = state.origBounds;

  try { if (termId) await chrome.windows.remove(termId); } catch (_) {}
  try {
    if (parentId && orig) await chrome.windows.update(parentId, { left: orig.left, top: orig.top, width: orig.width, height: orig.height, focused: true });
  } catch (_) {}

  state.enabled = false;
  state.parentId = null;
  state.termId = null;
  state.origBounds = null;
  state.adjusting = false;

  await sendToContent({ type: "state", enabled: false });
}

async function syncFromParent() {
  if (!state.enabled || state.adjusting) return;
  try {
    const cfg = await getCfg();
    const gap = Math.round(cfg.gap);
    const p = await chrome.windows.get(state.parentId);

    state.adjusting = true;
    await chrome.windows.update(state.termId, {
      left: p.left,
      top: p.top + p.height + gap,
      width: p.width
    });
    state.adjusting = false;
  } catch (_) {
    await disableDock();
  }
}

chrome.windows.onBoundsChanged.addListener(async (win) => {
  if (!state.enabled || state.adjusting) return;
  if (win.id === state.parentId) await syncFromParent();
});

chrome.windows.onRemoved.addListener(async (winId) => {
  if (!state.enabled) return;
  if (winId === state.parentId || winId === state.termId) await disableDock();
});

chrome.action.onClicked.addListener(async () => {
  const r = await toggle();
  if (r && r.ok) await sendToContent({ type: "state", enabled: state.enabled });
});

chrome.commands.onCommand.addListener(async (cmd) => {
  if (cmd === "toggle-dock") {
    const r = await toggle();
    if (r && r.ok) await sendToContent({ type: "state", enabled: state.enabled });
  }
});

chrome.runtime.onMessage.addListener((msg, _sender, sendResponse) => {
  (async () => {
    if (msg?.type === "toggle") return sendResponse(await toggle());
    if (msg?.type === "getState") return sendResponse({ enabled: state.enabled });
    if (msg?.type === "openOptions") { chrome.runtime.openOptionsPage(); return sendResponse({ ok: true }); }
    sendResponse({ ok: false });
  })();
  return true;
});
