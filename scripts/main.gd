extends Node

# Root controller. Owns the screen stack and routes between Home / Game /
# Aquarium / Collection. Keeps audio playing across screens.

var screen_root: Node

var screens := {
    "home": "res://scenes/home.tscn",
    "game": "res://scenes/game.tscn",
    "aquarium": "res://scenes/aquarium.tscn",
    "collection": "res://scenes/collection.tscn"
}

func _ready() -> void:
    screen_root = Node2D.new()
    screen_root.name = "ScreenRoot"
    add_child(screen_root)
    SignalBus.request_screen.connect(_go)
    _go("home")
    AudioManager.play_music("menu")

func _go(name: String) -> void:
    if not screens.has(name):
        return
    for c in screen_root.get_children():
        c.queue_free()
    var scn := load(screens[name])
    var inst = scn.instantiate()
    screen_root.add_child(inst)
    if name == "game":
        AudioManager.play_music("play")
    else:
        AudioManager.play_music("menu")
