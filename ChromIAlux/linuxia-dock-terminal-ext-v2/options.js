const DEFAULTS = { termUrl: "http://127.0.0.1:7681/", ratio: 0.62, gap: 6 };

async function load() {
  const cfg = await chrome.storage.local.get(DEFAULTS);
  document.getElementById("termUrl").value = cfg.termUrl;
  document.getElementById("ratio").value = String(cfg.ratio);
  document.getElementById("gap").value = String(cfg.gap);
}

async function save() {
  const termUrl = document.getElementById("termUrl").value.trim() || DEFAULTS.termUrl;
  const ratio = Math.min(0.80, Math.max(0.50, Number(document.getElementById("ratio").value || DEFAULTS.ratio)));
  const gap = Math.max(0, Math.min(40, Number(document.getElementById("gap").value || DEFAULTS.gap)));
  await chrome.storage.local.set({ termUrl, ratio, gap });
  alert("OK ✅ Options sauvées.");
}

document.getElementById("save").addEventListener("click", save);
load();
