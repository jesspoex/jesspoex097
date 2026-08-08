extends Control

# Living aquarium: shows collected fish swimming. Falls back to colored
# Rectangles when no fish sprite exists. This is the long-term visual hook.

@onready var tank: ColorRect = $VBox/Tank
@onready var count_label: Label = $VBox/CountLabel
@onready var back_btn: Button = $VBox/BackButton

var fish_nodes := []

func _ready() -> void:
    var bg: Color = GameConfig.color_to_color(
        _bg_color(SaveManager.get_skin("bg")))
    tank.color = bg
    _spawn_fish()
    count_label.text = "Fish: %d" % SaveManager.get_collected_fish().size()
    SignalBus.fish_collected.connect(_on_new_fish)

func _bg_color(id: String) -> String:
    var f := FileAccess.open("res://assets/data/skins.json", FileAccess.READ)
    var data: Dictionary = JSON.parse_string(f.get_as_text())
    f.close()
    for b in data["backgrounds"]:
        if b["id"] == id:
            return b["color"]
    return "#06182b"

func _spawn_fish() -> void:
    for n in fish_nodes:
        n.queue_free()
    fish_nodes.clear()
    var dex := _fishdex()
    var collected: Array = SaveManager.get_collected_fish()
    for fid in collected:
        var spec := _find_fish(dex, fid)
        if spec == null:
            continue
        var f := ColorRect.new()
        f.color = GameConfig.color_to_color(spec["color"])
        f.custom_minimum_size = Vector2(34, 20)
        f.size = Vector2(34, 20)
        tank.add_child(f)
        fish_nodes.append(f)
        f.position = Vector2(randf_range(20, 600), randf_range(30, 700))

func _find_fish(dex: Array, id: String) -> Dictionary:
    for d in dex:
        if d["id"] == id:
            return d
    return {}

func _on_new_fish(_id: String) -> void:
    AudioManager.play_sfx("fish_add")
    _spawn_fish()
    count_label.text = "Fish: %d" % SaveManager.get_collected_fish().size()

func _process(delta: float) -> void:
    for f in fish_nodes:
        f.position.x += delta * randf_range(20, 60) * (1 if randf() > 0.5 else -1)
        f.position.y += sin(Time.get_ticks_msec() / 500.0 + f.position.x) * 0.3
        f.position.x = wrapi(int(f.position.x), 10, int(tank.size.x - 40))
        f.position.y = clampf(f.position.y, 20, tank.size.y - 30)

func _on_back_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("home")

func _fishdex() -> Array:
    var f := FileAccess.open("res://assets/data/fishdex.json", FileAccess.READ)
    var arr: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    return arr if arr is Array else []
