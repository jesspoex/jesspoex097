# AdMob setup (monetization) — Tidy Tank

Tidy Tank ships with a **safe ad placeholder** in `core/ad_manager.gd`. It
simulates ads so the game runs with zero config. To go live and earn money:

## 1. Create an AdMob app + ad units
1. Go to https://admob.google.com and sign in with your Google account.
2. "Apps" → "Add app" → Android → enter your package name
   `com.tidytank.game` (set in `android/export_presets.cfg`).
3. Create **3 ad units**:
   - **Rewarded** (hint / undo / double daily / unlock tube / gift spin)
   - **Interstitial** (every N levels, cooldown-capped)
   - (Optional) **Banner** — not used by default; add later if you want.
4. Copy each **Ad Unit ID** (format `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)
   and your **App ID** (`ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`).

## 2. Install the godot-admob plugin (Godot 4)
- Repo: https://github.com/horusgh/godot-admob (or the currently maintained
  Godot 4 fork). Drop it into `android/plugins/` and enable it under
  Project → Export → Android → Plugins.
- The plugin adds an `AdMob` singleton (or similar node).

## 3. Wire the IDs in `core/ad_manager.gd`
Replace the constants near the top:
```gdscript
const REWARDED_AD_UNIT := "ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY"
const INTERSTITIAL_AD_UNIT := "ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ"
const REMOVE_ADS_IAP := "remove_ads"
```
Then replace the placeholder bodies:
```gdscript
func show_rewarded(reward_type: String) -> void:
    if SaveManager.has_remove_ads() and reward_type != "remove_ads":
        SignalBus.ad_reward_granted.emit(reward_type)
        return
    AdMob.load_rewarded(REWARDED_AD_UNIT)
    AdMob.show_rewarded()          # adapt to the plugin's API
    await AdMob.rewarded_closed     # await completion, then:
    SignalBus.ad_reward_granted.emit(reward_type)

func show_interstitial() -> void:
    if not can_show_interstitial():
        return
    _last_interstitial = Time.get_unix_time_from_system()
    AdMob.load_interstitial(INTERSTITIAL_AD_UNIT)
    AdMob.show_interstitial()
```
The rest of the game already emits/post-processes `SignalBus.ad_reward_granted`
and `SaveManager.remove_ads()`, so you do **not** need to touch the screens.

## 4. Consent (GDPR / EU / UK) — REQUIRED before personalized ads
- Add the **UMP (User Messaging Platform)** SDK or the godot-admob consent
  helper. Call `AdManager.request_consent()` and only show personalized ads
  after the user consents. Until then, show non-personalized ads or none.

## 5. IAP "Remove Ads"
- Set up the product `remove_ads` in Play Console → Monetize → Products →
  In-app products.
- In `purchase_remove_ads()` call the payment API and on success run
  `SaveManager.remove_ads()`.

## 6. Test before publishing
- Use AdMob **test ad unit IDs** first (shown in the AdMob dashboard) so you
  don't get flagged for invalid traffic.
- Confirm interstitial respects the cooldown (`AD_INTERSTITIAL_COOLDOWN_SEC`
  in `core/game_config.gd`) and never appears on the first 1-3 levels.

## Monetization model reminder (safe for Teen 13+)
- Rewarded video + interstitial + a cheap "Remove Ads" IAP.
- NO paid gacha / loot boxes (risk of "Mature" rating or rejection).
