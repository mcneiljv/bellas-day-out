extends Control

const GAME_SCENE: String = "res://scenes/main.tscn"
const CREDITS_SCENE: String = "res://scenes/credits.tscn"
const BOB_HEIGHT: float = 14.0
const BOB_DURATION: float = 0.5
# TODO: Add diff icons for sfx/music
const SOUND_ON := preload("res://assets/icons/sound.svg")
const SOUND_OFF := preload("res://assets/icons/mute.svg")

var can_quit: bool = not OS.has_feature("web") or OS.has_feature("ios")

@onready var sprite: Sprite2D = $Sprite2D
@onready var play_button: Button = $ButtonContainer/PlayButton
@onready var credits_button: Button = $ButtonContainer/CreditsButton
@onready var sfx_button: Button = $ButtonContainer/ToggleContainer/SfxButton
@onready var music_button: Button = $ButtonContainer/ToggleContainer/MusicButton
@onready var quit_button: Button = $ButtonContainer/QuitButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sfx_button.set_pressed_no_signal(AudioSettings.sfx_muted)
	music_button.set_pressed_no_signal(AudioSettings.music_muted)
	_update_icons()
	_update_text()
	sfx_button.toggled.connect(_on_sfx_toggled)
	music_button.toggled.connect(_on_music_toggled)
	play_button.pressed.connect(_on_play_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(get_tree().quit)
	# A web build can't close the browser tab, so the button would do nothing there.
	quit_button.visible = can_quit
	_start_bob()


func _input(event: InputEvent) -> void:
	if can_quit and event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_play_pressed() -> void:
	if not Music.playing:
		Music.play()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(CREDITS_SCENE)


func _start_bob() -> void:
	var base_y: float = sprite.position.y
	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "position:y", base_y - BOB_HEIGHT, BOB_DURATION)
	tween.tween_property(sprite, "position:y", base_y + BOB_HEIGHT, BOB_DURATION)


func _on_sfx_toggled(muted: bool) -> void:
	AudioSettings.set_sfx_muted(muted)
	_update_icons()
	_update_text()


func _on_music_toggled(muted: bool) -> void:
	AudioSettings.set_music_muted(muted)
	_update_icons()
	_update_text()


func _update_text() -> void:
	sfx_button.text = "SFX: Off" if AudioSettings.sfx_muted else "SFX: On"
	music_button.text = "Music: Off" if AudioSettings.music_muted else "Music: On"


func _update_icons() -> void:
	sfx_button.icon = SOUND_OFF if AudioSettings.sfx_muted else SOUND_ON
	music_button.icon = SOUND_OFF if AudioSettings.music_muted else SOUND_ON
