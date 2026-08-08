extends Node

# Satisfying audio. Two buses (Music / SFX) with separate volume + mute.
# Loads .ogg from res://assets/audio/ if present; silently skips missing ones.
# SFX get a small random pitch shift so repeats feel organic, not robotic.

const SFX_FILES := {
    "ball_drop": "res://assets/audio/sfx_ball_drop",
    "ball_pick": "res://assets/audio/sfx_ball_pick",
    "level_win": "res://assets/audio/sfx_level_win",
    "hint": "res://assets/audio/sfx_hint",
    "undo": "res://assets/audio/sfx_undo",
    "restart": "res://assets/audio/sfx_restart",
    "fish_add": "res://assets/audio/sfx_fish_add",
    "reward": "res://assets/audio/sfx_reward",
    "gift": "res://assets/audio/sfx_gift",
    "ui_tap": "res://assets/audio/sfx_ui_tap",
    "error": "res://assets/audio/sfx_error"
}
const MUSIC_FILES := {
    "menu": "res://assets/audio/music_menu",
    "play": "res://assets/audio/music_play"
}

# Tries .wav then .ogg for each name (Godot imports both natively).
func _resolve(path: String) -> String:
    for ext in [".wav", ".ogg"]:
        if FileAccess.file_exists(path + ext):
            return path + ext
    return ""

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_cache := {}
var _muted := false
var _volume_sfx := 0.9
var _volume_music := 0.5

func _ready() -> void:
    _ensure_buses()
    _muted = SaveManager.is_muted()
    _music_player = AudioStreamPlayer.new()
    _music_player.bus = "Music"
    add_child(_music_player)
    _preload_sfx()
    SignalBus.ui_muted_changed.connect(_on_mute_changed)

func _preload_sfx() -> void:
    for key in SFX_FILES:
        var p := _resolve(SFX_FILES[key])
        if p != "":
            _sfx_cache[key] = load(p)

func _ensure_buses() -> void:
    for name in ["Music", "SFX"]:
        if AudioServer.get_bus_index(name) == -1:
            AudioServer.add_bus()
            AudioServer.set_bus_name(AudioServer.bus_count - 1, name)
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), _muted)
    AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), _muted)

func _on_mute_changed(m: bool) -> void:
    _muted = m
    AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), m)
    AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), m)

func play_sfx(name: String) -> void:
    if _muted or not _sfx_cache.has(name):
        return
    var p := _get_sfx_player()
    p.stream = _sfx_cache[name]
    p.pitch_scale = randf_range(0.92, 1.08)   # organic variation
    p.volume_db = linear_to_db(_volume_sfx)
    p.play()

func _get_sfx_player() -> AudioStreamPlayer:
    for p in _sfx_pool:
        if not p.playing:
            return p
    var p := AudioStreamPlayer.new()
    p.bus = "SFX"
    add_child(p)
    _sfx_pool.append(p)
    return p

func play_music(name: String) -> void:
    var path := _resolve(MUSIC_FILES.get(name, ""))
    if _muted or path == "":
        return
    var stream = load(path)
    if _music_player.stream == stream and _music_player.playing:
        return
    _music_player.stream = stream
    _music_player.volume_db = linear_to_db(_volume_music)
    _music_player.play()

func stop_music() -> void:
    _music_player.stop()

func set_sfx_volume(v: float) -> void:
    _volume_sfx = clampf(v, 0.0, 1.0)
func set_music_volume(v: float) -> void:
    _volume_music = clampf(v, 0.0, 1.0)
