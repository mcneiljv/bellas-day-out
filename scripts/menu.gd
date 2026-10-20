extends Control

const GAME_SCENE := "res://scenes/main.tscn"

@onready var play_button: Button = $Background/CenterContainer/VBoxContainer/PlayButton
@onready var sfx_button: Button = $Background/CenterContainer/VBoxContainer/SfxButton
@onready var music_button: Button = $Background/CenterContainer/VBoxContainer/MusicButton
@onready var quit_button: Button = $Background/CenterContainer/VBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sfx_button.set_pressed_no_signal(AudioSettings.sfx_muted)
	music_button.set_pressed_no_signal(AudioSettings.music_muted)
	sfx_button.toggled.connect(AudioSettings.set_sfx_muted)
	music_button.toggled.connect(AudioSettings.set_music_muted)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(get_tree().quit)
	# A web build can't close the browser tab, so the button would do nothing there.
	quit_button.visible = not OS.has_feature("web")
	play_button.grab_focus()

func _on_play_pressed() -> void:
	if not Music.playing:
		Music.play()
	get_tree().change_scene_to_file(GAME_SCENE)
