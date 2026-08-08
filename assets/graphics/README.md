# Graphics assets

The game ships with **procedural flat-color UI** (no images required), but you
can drop replacements here:

- icon.png           — app icon, 512x512 (referenced by project.godot)
- bg_*.png           — aquarium / menu backgrounds
- fish_*.png         — fish sprites (optional; ColorRects used as fallback)
- tube.png / ball.png — tube + ball art (optional)

All colors are driven by `assets/data/fishdex.json` and
`core/game_config.gd` so you can re-theme without touching code.
