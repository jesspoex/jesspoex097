extends Control

# Root controller. Owns the screen stack and routes between Title / Home /
# Game / Aquarium / Collection. Keeps audio playing across screens.
# This node IS a full-rect Control so child Control screens size correctly
# (adding Controls under a Node2D makes them zero-size / blank).

var screens := {
	"title": "res://scenes/title.tscn",
	"home": "res://scenes/home.tscn",
	"game": "res://scenes/game.tscn",
	"aquarium": "res://scenes/aquarium.tscn",
	"collection": "res://scenes/collection.tscn"
}

func _ready() -> void:
	SignalBus.request_screen.connect(_go)
	_go("title")
	AudioManager.play_music("menu")

func _go(name: String) -> void:
	if not screens.has(name):
		return
	for c in get_children():
		c.queue_free()
	var scn := load(screens[name])
	var inst = scn.instantiate()
	add_child(inst)
	if name == "game":
		AudioManager.play_music("play")
	else:
		AudioManager.play_music("menu")
