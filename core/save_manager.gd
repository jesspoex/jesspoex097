extends Node

# Player meta-state: coins, streak, daily rewards, collection, quests,
# power unlocks, offline earning, skins. Persists to user://save.json.
# This is the retention engine — every "come back tomorrow" hook lives here.

const SAVE_PATH := "user://save.json"
const OFFLINE_RATE := 2          # coins per hour away
const OFFLINE_CAP_HOURS := 8
const GIFT_CHANCE := 0.08        # chance a cleared level drops a surprise gift

var data := {}

func _ready() -> void:
    _load_or_init()
    _process_daily()

func _load_or_init() -> void:
    if FileAccess.file_exists(SAVE_PATH):
        var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
        var txt := f.get_as_text()
        f.close()
        var parsed: Variant = JSON.parse_string(txt)
        if parsed is Dictionary:
            data = parsed
    if data.is_empty():
        data = _default()

func _default() -> Dictionary:
    var today := Time.get_unix_time_from_system()
    return {
        "coins": 0,
        "gems": 0,
        "level_index": 0,
        "total_levels": 0,
        "hints_today": 0,
        "streak": 0,
        "last_daily": "",
        "last_seen_unix": today,
        "collected_fish": [],
        "skins": {"bottle": "default", "ball": "default", "bg": "reef"},
        "unlocked_powers": [],
        "quests": [],
        "remove_ads": false,
        "muted": false,
        "keys": 0
    }

func save() -> void:
    var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    f.store_string(JSON.stringify(data, "\t"))
    f.close()

# ---- Daily / streak / offline ---------------------------------------------
func _process_daily() -> void:
    var now := Time.get_unix_time_from_system()
    var today_str := Time.get_date_string_from_system()

    # Offline earning.
    var away_hours := int((now - float(data["last_seen_unix"])) / 3600)
    if away_hours >= 1:
        var earn := mini(away_hours, OFFLINE_CAP_HOURS) * OFFLINE_RATE
        add_coins(earn)
    data["last_seen_unix"] = now

    # Daily reward + streak.
    if data["last_daily"] != today_str:
        var diff := 999
        if data["last_daily"] != "":
            var last := Time.get_unix_time_from_datetime_string(data["last_daily"] + " 00:00:00")
            diff = int((now - last) / 86400)
        if diff == 1:
            data["streak"] = int(data["streak"]) + 1
        else:
            data["streak"] = 1
        data["last_daily"] = today_str
        data["hints_today"] = 0
        _generate_quests()
        var bonus := GameConfig.COINS_STREAK_BONUS * int(data["streak"])
        add_coins(GameConfig.COINS_PER_LEVEL + bonus)
        SignalBus.streak_changed.emit(int(data["streak"]))
        save()

# ---- Currency --------------------------------------------------------------
func get_coins() -> int: return int(data["coins"])
func get_gems() -> int: return int(data["gems"])
func add_coins(n: int) -> void:
    data["coins"] = int(data["coins"]) + n
    SignalBus.coins_changed.emit(int(data["coins"]))
    _add_quest_progress("coins", n)
    save()
func add_gems(n: int) -> void:
    data["gems"] = int(data["gems"]) + n
    SignalBus.gems_changed.emit(int(data["gems"]))
    save()

# ---- Level clear (core loop completion) ------------------------------------
func register_level_clear() -> void:
    data["level_index"] = int(data["level_index"]) + 1
    data["total_levels"] = int(data["total_levels"]) + 1
    add_coins(GameConfig.COINS_PER_LEVEL)
    _add_quest_progress("win", 1)
    SignalBus.level_completed.emit(int(data["level_index"]))
    # Grant keys when the NEXT level is the first of a new chapter.
    if int(data["level_index"]) % GameConfig.LEVELS_PER_CHAPTER == 0:
        var ch: Dictionary = GameConfig.chapter_for_level(int(data["level_index"]))
        if int(ch["locked"]) > 0:
            grant_keys(int(ch["locked"]))
    # Surprise gift dopamine spike.
    if randf() < GIFT_CHANCE:
        _grant_gift()
    save()

func _grant_gift() -> void:
    var dex := _fishdex()
    var uncollected := []
    for f in dex:
        if not (f["id"] in data["collected_fish"]):
            uncollected.append(f)
    if not uncollected.is_empty():
        var pick: Dictionary = uncollected[randi() % uncollected.size()]
        add_fish(pick["id"])
        SignalBus.ad_reward_granted.emit("gift_fish")
    else:
        add_gems(1)
        SignalBus.ad_reward_granted.emit("gift_gem")

# ---- Fish collection -------------------------------------------------------
func _fishdex() -> Array:
    var f := FileAccess.open("res://assets/data/fishdex.json", FileAccess.READ)
    var arr: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    return arr if arr is Array else []
func add_fish(id: String) -> void:
    if not (id in data["collected_fish"]):
        data["collected_fish"].append(id)
        SignalBus.fish_collected.emit(id)
        _add_quest_progress("fish", 1)
        save()
func get_collected_fish() -> Array: return data["collected_fish"]

# ---- Hints -----------------------------------------------------------------
func hints_left() -> int:
    return maxi(0, GameConfig.FREE_HINTS_PER_DAY - int(data["hints_today"]))
func use_hint() -> bool:
    if hints_left() > 0:
        data["hints_today"] = int(data["hints_today"]) + 1
        save()
        return true
    return false

# ---- Keys (unlock locked tubes in chapters 3-5) ---------------------------
func get_keys() -> int: return int(data["keys"])
func spend_key() -> void:
    data["keys"] = maxi(0, int(data["keys"]) - 1)
    save()
func grant_keys(n: int) -> void:
    data["keys"] = int(data["keys"]) + n
    save()

# ---- Skins / powers --------------------------------------------------------
func get_skin(kind: String) -> String: return data["skins"].get(kind, "default")
func set_skin(kind: String, id: String) -> void:
    data["skins"][kind] = id
    save()
func has_power(name: String) -> bool: return name in data["unlocked_powers"]
func unlock_power(name: String) -> void:
    if not has_power(name):
        data["unlocked_powers"].append(name)
        save()

# ---- Mute ------------------------------------------------------------------
func is_muted() -> bool: return bool(data["muted"])
func set_muted(m: bool) -> void:
    data["muted"] = m
    save()
    SignalBus.ui_muted_changed.emit(m)

# ---- Ads -------------------------------------------------------------------
func remove_ads() -> void:
    data["remove_ads"] = true
    save()
func has_remove_ads() -> bool: return bool(data["remove_ads"])

# ---- Quests ----------------------------------------------------------------
func _generate_quests() -> void:
    data["quests"] = [
        {"type": "win", "target": 3, "progress": 0, "reward_coins": 30, "claimed": false},
        {"type": "fish", "target": 1, "progress": 0, "reward_gems": 1, "claimed": false},
        {"type": "coins", "target": 50, "progress": 0, "reward_coins": 20, "claimed": false}
    ]
func get_quests() -> Array: return data["quests"]
func _add_quest_progress(type: String, amount: int) -> void:
    for q in data["quests"]:
        if q["type"] == type and not q["claimed"]:
            q["progress"] = mini(int(q["progress"]) + amount, int(q["target"]))
    save()
func claim_quest(index: int) -> bool:
    if index < 0 or index >= data["quests"].size():
        return false
    var q: Dictionary = data["quests"][index]
    if q["claimed"] or int(q["progress"]) < int(q["target"]):
        return false
    q["claimed"] = true
    if q.has("reward_coins"): add_coins(int(q["reward_coins"]))
    if q.has("reward_gems"): add_gems(int(q["reward_gems"]))
    save()
    return true
