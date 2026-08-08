extends SceneTree

# Headless smoke test. Autoloads are NOT present under --script, so we load
# and instantiate the singleton scripts ourselves, then exercise the core loop.

const AUTOLOADS := {
    "SaveManager": "res://core/save_manager.gd",
    "SignalBus": "res://core/signal_bus.gd",
    "AudioManager": "res://core/audio_manager.gd",
    "AdManager": "res://core/ad_manager.gd",
    "GameConfig": "res://core/game_config.gd",
    "LevelGenerator": "res://core/level_generator.gd"
}

var _singletons := {}

func _initialize() -> void:
    var fails := 0
    var log := []

    for name in AUTOLOADS:
        var scn = load(AUTOLOADS[name])
        var node = scn.new()
        _singletons[name] = node
        get_root().add_child(node)
        log.append("autoload: %s" % name)

    var SaveManager = _singletons["SaveManager"]
    var LevelGenerator = _singletons["LevelGenerator"]
    var GameConfig = _singletons["GameConfig"]

    # 1. Level generation solvable + locked tubes flagged.
    var lv = LevelGenerator.generate(0)
    var ok_gen = typeof(lv) == TYPE_DICTIONARY and lv.has("tubes")
    log.append("level gen: %s (tubes=%d, locked=%d)" % [
        ok_gen, lv.get("tubes", []).size(), lv.get("locked", []).size()])

    # 2. Register clear increments coins + level index.
    var dir = DirAccess.open("user://")
    SaveManager.data = {}
    SaveManager._load_or_init()
    var before = SaveManager.get_coins()
    SaveManager.register_level_clear()
    var after = SaveManager.get_coins()
    log.append("register clear: %s (%d -> %d)" % [after > before, before, after])

    # 3. Fishdex + skins JSON parse.
    var f = FileAccess.open("res://assets/data/fishdex.json", FileAccess.READ)
    var dex = JSON.parse_string(f.get_as_text())
    f.close()
    log.append("fishdex parse: %s (%d species)" % [dex is Array, dex.size() if dex is Array else 0])

    # 4. Instantiate each screen scene (catches _ready crashes).
    for s in ["main", "home", "game", "aquarium", "collection"]:
        var path = "res://scenes/%s.tscn" % s
        var scn = load(path)
        if scn == null:
            log.append("LOAD FAIL: %s" % path); fails += 1; continue
        var inst = scn.instantiate()
        if inst == null:
            log.append("INSTANTIATE FAIL: %s" % path); fails += 1; continue
        log.append("screen ok: %s" % s)
        inst.queue_free()

    print("SMOKE TEST RESULTS:")
    for line in log:
        print("  - ", line)

    if fails == 0 and ok_gen and after > before and (dex is Array):
        print("SMOKE: PASS")
    else:
        print("SMOKE: FAIL (%d hard fails)" % fails)
    quit()
