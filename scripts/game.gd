extends Control

# The sort puzzle. Tap a tube to pick its top ball, tap another to drop.
# Win when every tube holds a single color. Calls into LevelGenerator, drives
# AudioManager for juice, and reports clears to SaveManager (meta loop).

@onready var grid: VBoxContainer = $VBox/GameArea/TubeGrid
@onready var level_label: Label = $VBox/TopBar/LevelLabel
@onready var hint_btn: Button = $VBox/Controls/HintButton
@onready var undo_btn: Button = $VBox/Controls/UndoButton
@onready var restart_btn: Button = $VBox/Controls/RestartButton
@onready var home_btn: Button = $VBox/Controls/HomeButton

var level := {}
var tubes := []            # array of arrays of color-index ints
var locked := []           # tube indices that are locked
var selected := -1
var history := []          # stack of snapshots for undo
var ball_scene: PackedScene

func _ready() -> void:
    ball_scene = preload("res://scenes/ball.tscn")
    level = LevelGenerator.generate(SaveManager.data["level_index"])
    _build_tubes()
    level_label.text = "Level %d" % (SaveManager.data["level_index"] + 1)
    AudioManager.play_sfx("ui_tap")
    _refresh_controls()

func _build_tubes() -> void:
    tubes = level["tubes"].duplicate(true)
    locked = level["locked"].duplicate()
    for c in grid.get_children():
        c.queue_free()
    var cap: int = level["capacity"]
    for i in tubes.size():
        var col := VBoxContainer.new()
        col.alignment = BoxContainer.ALIGNMENT_END
        col.add_theme_constant_override("separation", 4)
        var panel := Panel.new()
        panel.custom_minimum_size = Vector2(90, 90 * cap + 16)
        var inner := VBoxContainer.new()
        inner.alignment = BoxContainer.ALIGNMENT_END
        panel.add_child(inner)
        grid.add_child(panel)
        _fill_tube(inner, i, cap)
        _wire_tube(panel, i)

func _fill_tube(inner: VBoxContainer, i: int, cap: int) -> void:
    for c in inner.get_children():
        c.queue_free()
    var t: Array = tubes[i]
    for s in range(cap - t.size()):
        var sp := Control.new()
        sp.custom_minimum_size = Vector2(70, 70)
        inner.add_child(sp)
    for ball_idx in t:
        var b := ball_scene.instantiate()
        var col: Color = GameConfig.color_to_color(GameConfig.SORT_COLORS[ball_idx])
        b.apply_color(col)
        inner.add_child(b)

func _wire_tube(panel: Panel, i: int) -> void:
    panel.gui_input.connect(_on_tube_input.bind(i))

func _on_tube_input(ev: InputEvent, i: int) -> void:
    if ev is InputEventMouseButton and ev.pressed and not ev.double_click:
        _on_tube_tapped(i)

func _on_tube_tapped(i: int) -> void:
    if i in locked:
        AudioManager.play_sfx("error")
        return
    if selected == -1:
        if tubes[i].is_empty():
            return
        selected = i
        AudioManager.play_sfx("ball_pick")
    else:
        if i == selected:
            selected = -1
            return
        if _can_move(selected, i):
            _push_history()
            var ball = tubes[selected].pop_back()
            tubes[i].append(ball)
            AudioManager.play_sfx("ball_drop")
            selected = -1
            _refresh_all()
            _check_win()
        else:
            AudioManager.play_sfx("error")
            selected = -1
    _refresh_controls()

func _can_move(from: int, to: int) -> bool:
    if tubes[from].is_empty():
        return false
    if tubes[to].size() >= level["capacity"]:
        return false
    if tubes[to].is_empty():
        return true
    return tubes[from][-1] == tubes[to][-1]

func _refresh_all() -> void:
    _build_tubes()
    _refresh_controls()

func _refresh_tube(_i: int) -> void:
    _build_tubes()

func _push_history() -> void:
    history.append(tubes.duplicate(true))

func _check_win() -> void:
    for t in tubes:
        if t.is_empty():
            continue
        var f = t[0]
        for b in t:
            if b != f:
                return
    # Won.
    AudioManager.play_sfx("level_win")
    SaveManager.register_level_clear()
    AdManager.show_interstitial()
    await get_tree().create_timer(0.8).timeout
    SignalBus.request_screen.emit("home")

func _on_hint_pressed() -> void:
    if SaveManager.use_hint():
        AudioManager.play_sfx("hint")
    else:
        AdManager.show_rewarded("hint")
    _refresh_controls()

func _on_undo_pressed() -> void:
    if history.is_empty():
        AudioManager.play_sfx("error")
        return
    tubes = history.pop_back()
    AudioManager.play_sfx("undo")
    selected = -1
    _refresh_all()

func _on_restart_pressed() -> void:
    AudioManager.play_sfx("restart")
    tubes = level["tubes"].duplicate(true)
    history.clear()
    selected = -1
    _refresh_all()

func _on_home_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("home")

func _refresh_controls() -> void:
    hint_btn.text = "Hint (%d left)" % SaveManager.hints_left()
    undo_btn.disabled = history.is_empty()
