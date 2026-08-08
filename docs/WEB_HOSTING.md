# Web build & hosting (GitHub Pages)

Tidy Tank runs in the browser — no install needed. Live demo:
**https://jesspoex.github.io/jesspoex097/**

## How it's built
The playable build lives on the `gh-pages` branch (root = exported Web files).
The source project stays on `main`. Deploy is done by exporting Godot to
Web, then publishing `web/` contents to `gh-pages`.

### Rebuild + redeploy (from a machine with Godot 4.3 + Web templates)
```bash
cd ~/tidy-tank
# 1. export
godot --headless --export-release "Web" "web/index.html"
# 2. publish to gh-pages (copies web/ to branch root + .nojekyll)
git checkout -B gh-pages
git rm -rf --cached . >/dev/null
git reset -q HEAD .
cp web/index.html web/index.js web/index.wasm web/index.pck \
   web/index.png web/index.icon.png web/index.apple-touch-icon.png \
   web/index.audio.worklet.js .
touch .nojekyll
git add -A
git commit -m "Web build update"
git push -f origin gh-pages
git checkout main
```
GitHub Pages rebuilds automatically. Allow ~1–2 min, then hard-refresh.

## Notes
- Requires a browser with WebGL2 (Chrome, Edge, Firefox, Safari 15+).
- On mobile, open the URL in the browser — touch works.
- iOS: Godot Web needs **real touch**, not the iOS "request desktop" mode.
- The web build is the same game as the Android build (shared code).
- `.nojekyll` disables Jekyll so the `.wasm`/`.pck` are served verbatim.
