# Audio assets

Satisfying placeholder SFX + music are **already included** as `.wav` files
(13 SFX + 2 music loops), generated procedurally. They load automatically —
you don't need to add anything to hear the game.

## Files present
SFX: `sfx_ball_drop`, `sfx_ball_pick`, `sfx_level_win`, `sfx_hint`,
`sfx_undo`, `sfx_restart`, `sfx_fish_add`, `sfx_reward`, `sfx_gift`,
`sfx_ui_tap`, `sfx_error` (all `.wav`).
Music: `music_menu`, `music_play` (`.wav`, ~8s loops).

## Swap for better audio (optional)
Drop your own file with the **same base name** (e.g. `sfx_ball_drop.ogg`) into
this folder. `core/audio_manager.gd` resolves `.wav` then `.ogg`, so your
replacement wins. Use `.ogg`/`.mp3` for smaller size in the final build.

## Free sources (commercial OK)
- SFX: freesound.org (CC0), kenney.nl, sfxr/bfxr generators
- Music: YouTube Audio Library, Pixabay Music, Incompetech (Kevin MacLeod)
