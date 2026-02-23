(function () {
  const BAR_ID = "linuxiaDockBar";
  const TOAST_ID = "linuxiaDockToast";

  function toast(msg) {
    let el = document.getElementById(TOAST_ID);
    if (!el) {
      el = document.createElement("div");
      el.id = TOAST_ID;
      document.documentElement.appendChild(el);
    }
    el.textContent = msg;
    el.style.display = "block";
    clearTimeout(window.__linuxiaToastTimer);
    window.__linuxiaToastTimer = setTimeout(() => (el.style.display = "none"), 4500);
  }

  function ensureBar(stateEnabled) {
    let bar = document.getElementById(BAR_ID);
    if (bar) return updateBar(stateEnabled);

    bar = document.createElement("div");
    bar.id = BAR_ID;

    const label = document.createElement("div");
    label.textContent = "LinuxIA Dock";
    label.style.opacity = "0.9";

    const pill = document.createElement("div");
    pill.className = "pill " + (stateEnabled ? "on" : "off");
    pill.textContent = stateEnabled ? "TERMINAL ON" : "TERMINAL OFF";
    pill.id = "linuxiaDockPill";

    const btn = document.createElement("button");
    btn.textContent = "Toggle";
    btn.addEventListener("click", async () => {
      chrome.runtime.sendMessage({ type: "toggle" }, (resp) => {
        if (resp && resp.ok) updateBar(resp.enabled);
        if (resp && resp.warn) toast(resp.warn);
      });
    });

    const opt = document.createElement("button");
    opt.textContent = "Options";
    opt.addEventListener("click", () => chrome.runtime.sendMessage({ type: "openOptions" }));

    bar.appendChild(label);
    bar.appendChild(pill);
    bar.appendChild(btn);
    bar.appendChild(opt);

    document.documentElement.appendChild(bar);
  }

  function updateBar(enabled) {
    const pill = document.getElementById("linuxiaDockPill");
    if (!pill) return;
    pill.className = "pill " + (enabled ? "on" : "off");
    pill.textContent = enabled ? "TERMINAL ON" : "TERMINAL OFF";
  }

  chrome.runtime.sendMessage({ type: "getState" }, (resp) => {
    ensureBar(resp && resp.enabled);
  });

  chrome.runtime.onMessage.addListener((msg) => {
    if (msg && msg.type === "state") updateBar(!!msg.enabled);
    if (msg && msg.type === "warn") toast(msg.message || "Avertissement.");
  });
})();
