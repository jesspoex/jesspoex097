extends Node

# Safe ad placeholder for 13+ monetization.
#
# This simulates ads so the game runs with zero setup. To go live:
#   1. Install the "godot-admob" (Godot 4) plugin and enable it in
#      Project > Export > Android.
#   2. Put your real AdMob App ID + Ad Unit IDs in these constants.
#   3. Replace the bodies of show_rewarded() / show_interstitial() with the
#      plugin calls, keeping the same emit() signals so the rest of the game
#      is unchanged.
#   4. REQUIRED for EU/GDPR: integrate UMP / Consent SDK and only show
#      personalized ads after consent. request_consent() is the hook.
#
# Monetization model (safe for Teen):
#   - Rewarded video: hint, undo, double daily, unlock tube, gift spin.
#   - Interstitial: every N levels, cooldown-capped (never every level).
#   - IAP "Remove Ads": the highest-converting revenue for sort games.
#   DO NOT add paid gacha / loot boxes — that risks a "Mature" rating or
#   rejection on the Play Store.

const REWARDED_AD_UNIT := "ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy"
const INTERSTITIAL_AD_UNIT := "ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz"
const REMOVE_ADS_IAP := "remove_ads"

var _last_interstitial := -999.0
var _consent_given := false

func request_consent() -> void:
    # Hook for UMP. Until wired, treat as granted (test only — REAL apps
    # must gate personalized ads on actual consent).
    _consent_given = true

func can_show_interstitial() -> bool:
    if SaveManager.has_remove_ads():
        return false
    var now := Time.get_unix_time_from_system()
    return (now - _last_interstitial) >= GameConfig.AD_INTERSTITIAL_COOLDOWN_SEC

# Simulated rewarded ad. Pass a reward_type the game understands.
func show_rewarded(reward_type: String) -> void:
    if SaveManager.has_remove_ads() and reward_type != "remove_ads":
        SignalBus.ad_reward_granted.emit(reward_type)
        return
    # Real plugin: load + show; on completion emit the signal.
    # Here we simulate a short delay then grant.
    await get_tree().create_timer(0.4).timeout
    SignalBus.ad_reward_granted.emit(reward_type)

func show_interstitial() -> void:
    if not can_show_interstitial():
        return
    _last_interstitial = Time.get_unix_time_from_system()
    # Real plugin: show interstitial here.

func purchase_remove_ads() -> void:
    # Real: OS.purchase(REMOVE_ADS_IAP). On success:
    SaveManager.remove_ads()
