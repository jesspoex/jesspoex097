# Tidy Tank

A relaxing **ball/water-sort puzzle** for teens (13+, "Teen" rating) with a
**living aquarium collection meta** — built to keep players coming back.

Why this design keeps players hooked (the gaps we filled):
- **Satisfying audio** — every ball drop / win / fish catch has a juicy sound
  with pitch randomization. Lo-fi menu + play music. (Toggleable.)
- **Double-loop retention** — clear a puzzle AND fill your aquarium.
- **Collection (Fishdex)** — 50+ species goal = long-term reason to return.
- **Daily reward + streak + quests** — reason to open the app every day.
- **Offline earning + weekly events** — the "come back tomorrow" hook.
- **Power growth** — unlock tubes/helpers so the player feels stronger.
- **Surprise gifts** — random reward boxes for dopamine spikes.
- **Monetization that is safe for 13+** — rewarded video + interstitial +
  a cheap "Remove Ads" IAP. NO paid gacha / loot boxes.

## Run it (Godot 4.3+)
1. Install [Godot 4.3](https://godotengine.org/download).
2. Open this folder as a project.
3. Press F5 (run `res://scenes/main.tscn`).

The game runs with **zero assets** — drop `.ogg` SFX/music into
`res://assets/audio/` (filenames listed in `assets/audio/README.md`) and
`.png` art into `res://assets/graphics/` to skin it.

## Project layout
```
core/        autoload singletons (save, audio, ads, config, level gen, signals)
scripts/     screen logic (main, home, game, aquarium, collection)
scenes/      .tscn roots
assets/      audio + graphics placeholders + data json (fishdex, skins)
```

## Monetization (AdMob)
`core/ad_manager.gd` is a safe placeholder: it simulates ads when the
`godot-admob` plugin is absent, and is the single place to wire real ads.
See comments there. Remember: configure **UMP / Consent SDK** for GDPR/EU
before publishing.

## Publish checklist (Play Console, one-time $25)
- Build **AAB** (not APK) via the Android export preset.
- Provide a **privacy policy** URL and fill the **Data Safety** form
  (AdMob collects Advertising ID — disclose it).
- New apps require a **14-day closed test with 20 testers** before production.
- Content rating questionnaire → choose **Teen (13+)**, answer ads honestly.

## Push to GitHub
This repo is local. To push to YOUR GitHub:
```
cd ~/tidy-tank
git remote add origin https://github.com/<you>/<repo>.git
git push -u origin main
```
If you use a token, use `https://<TOKEN>@github.com/<you>/<repo>.git` or run
`gh auth login`. Ask the assistant to do it for you once credentials exist.

## License
MIT — do what you want, make money, just keep the notice.
