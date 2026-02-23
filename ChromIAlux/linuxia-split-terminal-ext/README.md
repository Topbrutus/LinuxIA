# linuxia-split-terminal-ext v1.4.0

Chrome MV3 extension: split ChatGPT (top) + ttyd terminal dock (bottom).

## Architecture
- **content.js** — injected in ChatGPT page: dock UI + terminal HUD overlay (live buffer)
- **bridge.js** — injected in `http://127.0.0.1:7681/*` (ttyd): reads xterm buffer, relays to background
- **background.js** — service worker relay: bridges ChatGPT ↔ ttyd + WebSocket fallback
- **dock.html** — static page (kept for reference)

## Features
- `Ctrl+Shift+Y` toggle dock  
- `Ctrl+Shift+L` toggle scan mode (selection → terminal)  
- Context menu: "→ LinuxIA Terminal"
- **Live HUD**: small overlay showing last 30 lines of terminal buffer
- **postMessage bridge**: ChatGPT can send commands; terminal output visible in HUD

## Install
1. `chrome://extensions` → Load unpacked → select this folder
2. Start ttyd: `ttyd -p 7681 bash`
3. Click icon or `Ctrl+Shift+Y` on ChatGPT
