extends Control

# Title / splash screen. First thing the player sees: the game name, a little
# animated mascot, and a big PLAY button. Solves "blank / what is this game".

@onready var title_label: Label = $VBox/TitleLabel
@onready var play_btn: Button = $VBox/PlayButton
@onready var mute_btn: Button = $VBox/MuteButton
@onready var mascot: ColorRect = $VBox/Mascot

func _ready() -> void:
	title_label.text = "TIDY TANK"
	mute_btn.text = "Mute: %s" % ("ON" if SaveManager.is_muted() else "OFF")
	play_btn.pressed.connect(_on_play)
	mute_btn.pressed.connect(_on_mute)
	AudioManager.play_sfx("ui_tap")

func _on_play() -> void:
	AudioManager.play_sfx("reward")
	SignalBus.request_screen.emit("home")

func _on_mute() -> void:
	SaveManager.set_muted(not SaveManager.is_muted())
	AudioManager.play_sfx("ui_tap")
	mute_btn.text = "Mute: %s" % ("ON" if SaveManager.is_muted() else "OFF")

func _process(delta: float) -> void:
	# gentle bob
	mascot.position.y = sin(Time.get_ticks_msec() / 400.0) * 6.0
