extends Control

# Fishdex: the completionist goal. Shows every species and whether it is
# caught. Long-term reason to keep playing. Also a skins selector.

@onready var grid: GridContainer = $VBox/Grid
@onready var back_btn: Button = $VBox/BackButton
@onready var skins_box: HBoxContainer = $VBox/Skins

func _ready() -> void:
    _render()
    SignalBus.fish_collected.connect(_on_caught)

func _render() -> void:
    for c in grid.get_children():
        c.queue_free()
    var dex := _fishdex()
    var collected: Array = SaveManager.get_collected_fish()
    for d in dex:
        var cell := VBoxContainer.new()
        var swatch := ColorRect.new()
        swatch.color = GameConfig.color_to_color(d["color"])
        swatch.custom_minimum_size = Vector2(60, 40)
        var label := Label.new()
        label.text = d["name"] if (d["id"] in collected) else "??? (%s)" % d["rarity"]
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        cell.add_child(swatch)
        cell.add_child(label)
        grid.add_child(cell)
    _render_skins()

func _render_skins() -> void:
    for c in skins_box.get_children():
        c.queue_free()
    var f := FileAccess.open("res://assets/data/skins.json", FileAccess.READ)
    var data: Dictionary = JSON.parse_string(f.get_as_text())
    f.close()
    var kinds := {"bottle": "Bottle", "ball": "Ball", "bg": "Tank"}
    for kind in kinds:
        for opt in data[kind + "s"]:
            var b := Button.new()
            b.text = "%s: %s" % [kinds[kind], opt["name"]]
            if SaveManager.get_skin(kind) == opt["id"]:
                b.text += " [x]"
            b.pressed.connect(_on_skin.bind(kind, opt["id"]))
            skins_box.add_child(b)

func _on_skin(kind: String, id: String) -> void:
    SaveManager.set_skin(kind, id)
    AudioManager.play_sfx("ui_tap")
    _render()

func _on_caught(_id: String) -> void:
    _render()

func _on_back_pressed() -> void:
    AudioManager.play_sfx("ui_tap")
    SignalBus.request_screen.emit("home")

func _fishdex() -> Array:
    var f := FileAccess.open("res://assets/data/fishdex.json", FileAccess.READ)
    var arr: Variant = JSON.parse_string(f.get_as_text())
    f.close()
    return arr if arr is Array else []
