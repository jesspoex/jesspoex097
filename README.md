# Tidy Tank

A relaxing **ball/water-sort puzzle** for teens (13+, "Teen" rating) with a
**living aquarium collection meta** — built to keep players coming back.

Why this design keeps players hooked (the gaps we filled):
- **Satisfying audio** — every ball drop / win / fish catch has a juicy sound
  with pitch randomization. Lo-fi menu + play music. (Toggleable, WAV included.)
- **Double-loop retention** — clear a puzzle AND fill your aquarium.
- **Collection (Fishdex)** — 12 species goal = long-term reason to return.
- **Daily reward + streak + quests** — reason to open the app every day.
- **Offline earning + weekly events** — the "come back tomorrow" hook.
- **Power growth** — unlock keys to open locked tubes (chapters 3-5).
- **Surprise gifts** — random reward boxes for dopamine spikes.
- **Monetization that is safe for 13+** — rewarded video + interstitial +
  a cheap "Remove Ads" IAP. NO paid gacha / loot boxes.

## Status
- [x] Core sort gameplay (solvable procedural levels)
- [x] Chapters 1-5 difficulty curve with **locked tubes** (unlock via keys / rewarded ad)
- [x] Living aquarium (collected fish swim)
- [x] Fishdex collection + skin selector
- [x] Daily reward + streak + 3 daily quests + offline earning
- [x] Satisfying audio (13 placeholder WAVs included) + mute toggle
- [x] Safe ad placeholder (rewarded/interstitial/remove-ads) — wire AdMob in `core/ad_manager.gd`
- [x] App icon (512 PNG)
- [x] Android export preset (`android/export_presets.cfg`) — produces AAB
- [x] Privacy policy + Play Store Data Safety checklist (`docs/`)
- [x] Verified: compiles clean + runtime smoke test passes (Godot 4.3)

## Run it (Godot 4.3+)
1. Install [Godot 4.3](https://godotengine.org/download).
2. Open this folder as a project.
3. Press F5 (run `res://scenes/main.tscn`).

The game runs with **assets included** — audio + icon are bundled. Drop your
own `.ogg`/`.png` with the same names to replace them.

## Project layout
```
core/        autoload singletons (save, audio, ads, config, level gen, signals)
scripts/     screen logic (main, home, game, aquarium, collection)
scenes/      .tscn roots
assets/      audio (WAV) + graphics (icon) + data json (fishdex, skins)
docs/        PRIVACY_POLICY.md, PLAY_STORE_DATA_SAFETY.md, ADMOB_SETUP.md
android/     export_presets.cfg (AAB build)
```

## Monetization (AdMob)
`core/ad_manager.gd` is a safe placeholder. See `docs/ADMOB_SETUP.md` for the
exact wiring. **Required:** integrate UMP / Consent SDK for GDPR/EU.

## Publish checklist (Play Console, one-time $25)
- Build **AAB** via the Android export preset.
- Provide a **privacy policy** URL (host `docs/PRIVACY_POLICY.md`) + fill the
  **Data Safety** form (see `docs/PLAY_STORE_DATA_SAFETY.md`).
- New apps require a **14-day closed test with 20 testers** before production.
- Content rating → **Teen (13+)**, answer ads honestly.

## Push to GitHub
```
cd ~/tidy-tank
git remote add origin https://github.com/jesspoex/jesspoex097.git
git push -u origin main
```

## License
MIT.
