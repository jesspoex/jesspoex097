# HANDOFF — Tidy Tank (Godot 4.3 sort-puzzle + aquarium)

> Dipakai untuk serah-terima ke AI coding lain (Claude / Codex / opencode).
> Baca file ini dulu SEBELUM ngubah kode. Semua path relatif ke root repo.

## Apa ini
Game puzzle **ball/water-sort** untuk remaja (rating Teen 13+) dengan meta
**akuarium koleksi**. Target: betah main lama + bisa cuan (iklan AdMob).
Engine **Godot 4.3** (gratis, export Android AAB + Web WASM).

## Status sekarang (terverifikasi, Godot 4.3)
- COMPILE PASS (no script errors), runtime SMOKE PASS (semua layar instantiate).
- Gameplay sort jalan: tap botol → pindah bola ke botol lain, menang kalau tiap
  botol 1 warna penuh. Level di-generate procedural & SOLVABLE.
- 5 layar: Title (splash + PLAY), Home (daily/streak/quest), Game (sort),
  Aquarium (koleksi ikan), Collection (Fishdex 12 spesies).
- Audio: 13 SFX WAV + 2 musik loop (sudah ada di assets/audio).
- Monetize: `core/ad_manager.gd` = placeholder aman (rewarded/interstitial/
  remove-ads). BELUM disambung ke AdMob asli.
- Web demo LIVE: https://jesspoex.github.io/jesspoex097/ (branch `gh-pages`).
- Repo: https://github.com/jesspoex/jesspoex097  (branch `main`).

## Verifikasi lokal (wajib jalanin tiap ubah kode)
```bash
cd ~/tidy-tank
godot --headless --script smoke_test.gd   # harus PRINT "SMOKE: PASS"
```
(Renamed `godot` = binary Godot 4.3. Atau `~/godot4`.)
smoke_test.gd mengecek: autoload, level solvable, coin loop, parse fishdex,
dan instantiate semua scene. Kalau FAIL, JANGAN lanjut sebelum benerin.

## Cara jalanin / export
- Editor: buka folder ini di Godot 4.3 → F5 (main_scene = res://scenes/main.tscn).
- Web: `godot --headless --export-release "Web" "web/index.html"` lalu isi
  `web/` di-root branch `gh-pages` + `.nojekyll` (lihat docs/WEB_HOSTING.md).
- Android AAB: preset "Android" di export_presets.cfg → butuh keystore.

## ⚠️ KENAPA "KURANG MENARIK" (ini prioritas lu perbaiki)
Game sekarang FUNGSIONAL tapi **monoton** — cuma sort warna polos tanpa
tension/goal instan. Yang bikin pemain cepat bosan:
1. Gak ada tujuan di depan mata (cuma "urutin warna").
2. Gak ada feedback kejutan / combo / power moment.
3. Akuarium baru keisi LAMA (butuh puluhan level).
4. Gak ada tantangan variasi (semua level = sort biasa).

## List konkret biar SERU (Claude bisa eksekusi satu-satu)
- [ ] **Tutorial interaktif** level 1: panah + teks "tap botol, pindah ke
      warna sama" yang hilang setelah 1 move.
- [ ] **Power-up / boost**: shuffle, undo gratis 1x/level, "bomb" buat buang
      bola, freeze timer. Droppable dari reward box.
- [ ] **Combo & juice**: chain move cepat kasih "PERFECT!" + koin bonus +
      partikel. Audio pitch naik tiap combo.
- [ ] **Mode Time Attack / Daily Challenge**: skor, leaderboard lokal.
- [ ] **Goal instan**: tiap level kasih target ("kumpulkan 3 ikan langka")
      yang langsung masuk akuarium = dopamine tiap main.
- [ ] **Event mingguan**: tema warna / ikan spesial terbatas.
- [ ] **Visual upgrade**: ganti flat ColorRect jadi sprite ikan/gelembung
      (assets/graphics/ sudah disiapin buat drop-in).
- [ ] **Narrative tipis**: "selamatkan akuarium dari polusi" → sort = bersihin.

## Konvensi kode (jangan langgar)
- Autoload (singleton): SaveManager, AudioManager, AdManager, GameConfig,
  LevelGenerator, SignalBus. Semua state global lewat ini.
- Routing layar: `SignalBus.request_screen.emit("home"|"game"|"aquarium"|
  "collection"|"title")`. Main scene = Control full-rect (JANGAN Node2D —
  bikin layar blank, sudah kejadian sekali).
- SFX: `AudioManager.play_sfx("nama")`. Nama wajib ada di SFX_FILES.
- Simpan progress: `SaveManager.data[...]` lalu `SaveManager.save()`.

## Hal yang SUDAH diketahui HATI-HATI
- `Control` di bawah `Node2D` = ukuran 0 = blank screen. Root selalu Control.
- `.tscn` tiap node (kecuali root) WAJIB punya `parent="..."`.
- AdMob: jangan hardcode App ID. Taruh di `core/ad_manager.gd`, butuh UMP
  consent buat EU (wajib buat rilis).
- Jangan commit `.keystore`, `user://`, `.godot/`.

## Langkah pertama buat AI penerus
1. Baca file ini + jalanin smoke_test (pastikan PASS).
2. Pilih 1 item dari "biar SERU" di atas, implement, jalanin smoke_test lagi.
3. Kalau mau web: rebuild + push gh-pages. Kalau mau Android: export AAB.
4. Jangan ubah arsitektur tanpa alasan kuat.
