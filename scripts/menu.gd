extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"

var can_quit: bool = not OS.has_feature("web") or OS.has_feature("ios")

@onready var play_button: Button = $ButtonContainer/PlayButton
@onready var sfx_button: Button = $ButtonContainer/ToggleContainer/SfxButton
@onready var music_button: Button = $ButtonContainer/ToggleContainer/MusicButton
@onready var quit_button: Button = $ButtonContainer/QuitButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sfx_button.set_pressed_no_signal(AudioSettings.sfx_muted)
	music_button.set_pressed_no_signal(AudioSettings.music_muted)
	sfx_button.toggled.connect(AudioSettings.set_sfx_muted)
	music_button.toggled.connect(AudioSettings.set_music_muted)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(get_tree().quit)
	# A web build can't close the browser tab, so the button would do nothing there.
	quit_button.visible = can_quit
	play_button.grab_focus()


func _input(event: InputEvent) -> void:
	if can_quit and event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_play_pressed() -> void:
	if not Music.playing:
		Music.play()
	get_tree().change_scene_to_file(GAME_SCENE)
