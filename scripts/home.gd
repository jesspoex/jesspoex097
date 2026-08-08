extends Control

# Home screen: the daily hook. Shows coins, streak calendar, daily reward,
# quest list, and buttons into Game / Aquarium / Collection.

@onready var coin_label: Label = $VBox/TopBar/CoinLabel
@onready var gem_label: Label = $VBox/TopBar/GemLabel
@onready var streak_label: Label = $VBox/StreakLabel
@onready var daily_btn: Button = $VBox/DailyButton
@onready var quest_box: VBoxContainer = $VBox/QuestBox
@onready var mute_btn: Button = $VBox/TopBar/MuteButton

func _ready() -> void:
    _refresh()
    SignalBus.coins_changed.connect(_on_coin)
    SignalBus.gems_changed.connect(_on_gem)
    SignalBus.streak_changed.connect(_on_streak)
    SignalBus.ui_muted_changed.connect(_on_mute)
    _render_quests()

func _refresh() -> void:
    coin_label.text = "Coins: %d" % SaveManager.get_coins()
    gem_label.text = "Gems: %d" % SaveManager.get_gems()
    streak_label.text = "Streak: %d day(s)" % SaveManager.data["streak"]
    mute_btn.text = "Mute: %s" % ("ON" if SaveManager.is_muted() else "OFF")

func _on_coin(_v): coin_label.text = "Coins: %d" % SaveManager.get_coins()
func _on_gem(_v): gem_label.text = "Gems: %d" % SaveManager.get_gems()
func _on_streak(_v): _refresh()
func _on_mute(_m): _refresh()

func _render_quests() -> void:
    for c in quest_box.get_children():
        c.queue_free()
    for i in SaveManager.get_quests().size():
        var q: Dictionary = SaveManager.get_quests()[i]
        var b := Button.new()
        var desc := "Win %d levels" % q["target"] if q["type"] == "win" \
            else ("Catch %d fish" % q["target"] if q["type"] == "fish" \
            else "Earn %d coins" % q["target"])
        b.text = "%s  (%d/%d)  %s" % [desc, q["progress"], q["target"],
            "[claimed]" if q["claimed"] else ""]
        b.disabled = q["claimed"] or int(q["progress"]) < int(q["target"])
        b.pressed.connect(_on_quest_pressed.bind(i))
        quest_box.add_child(b)

func _on_quest_pressed(i: int) -> void:
    if SaveManager.claim_quest(i):
        AudioManager.play_sfx("reward")
        _render_quests()

func _on_play_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("game")

func _on_aquarium_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("aquarium")

func _on_collection_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("collection")

func _on_daily_pressed() -> void:
    AudioManager.play_sfx("reward")
    # Daily reward is granted by SaveManager on daily roll; this is a manual
    # claim confirmation with a chance at a surprise gift.
    if randf() < 0.15:
        SaveManager.add_gems(1)
    _refresh()

func _on_mute_pressed() -> void:
    SaveManager.set_muted(not SaveManager.is_muted())
    AudioManager.play_sfx("ui_tap")
