extends Node2D

## The current phase of the game loop.
enum State {
	## Waiting for the first tap. The player hovers and no bones spawn.
	READY,
	## The player is flying, bones are spawning, and taps hop.
	PLAYING,
	## The run has ended. Taps restart the game once `can_restart` is true.
	GAME_OVER,
}

const MENU_SCENE: String = "res://scenes/menu.tscn"
# NOTE: Controls difficulty scaling
const BASE_SPEED: float = 200.0
# NOTE: If difficulty curve is too high, lower MAX_SPEED first
const MAX_SPEED: float = 360.0
const BASE_INTERVAL: float = 1.6
const MIN_INTERVAL: float = 1.0

const BONE_SCENE: PackedScene = preload("res://scenes/bone.tscn")
const BONE_SPAWN_X: float = 540.0
const GAP_CENTER_MIN: float = 180.0
const GAP_CENTER_MAX: float = 616.0

## Which phase the game is in. Changed only by `start_game()` and `game_over()`.
var state: State = State.READY
var can_restart: bool = false
var score: int = 0
var layer_speeds: Dictionary = {}

## The player. Used to flap, start, and kill it, and to listen for its `crashed` signal.
@onready var player: Player = $Player
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var message_label: Label = $UI/MessageLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var bones: Node2D = $Bones
@onready var spawn_timer: Timer = $SpawnTimer
@onready var back_button: Button = $UI/BackButton


func _ready() -> void:
	player.crashed.connect(game_over)
	message_label.text = "Tap or press Space to start"
	spawn_timer.timeout.connect(spawn_bone)
	back_button.pressed.connect(go_to_menu)
	for layer: Parallax2D in get_tree().get_nodes_in_group("parallax_layers"):
		layer_speeds[layer] = layer.autoscroll
		layer.autoscroll = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		go_to_menu()
		return
	if not event.is_action_pressed("jump"):
		return
	match state:
		State.READY:
			start_game()
		State.PLAYING:
			player.flap()
		State.GAME_OVER:
			if can_restart:
				get_tree().reload_current_scene()


func start_game() -> void:
	state = State.PLAYING
	message_label.hide()
	player.start()
	player.flap()
	spawn_bone()
	spawn_timer.start()
	set_background_scroll(true)


func game_over() -> void:
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER
	spawn_timer.stop()
	get_tree().call_group("bones", "set_physics_process", false)
	set_background_scroll(false)
	player.die()
	game_over_label.text = "Game Over"
	message_label.text = "Tap to restart"
	message_label.show()
	await get_tree().create_timer(0.6).timeout
	can_restart = true


func go_to_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_bone_scored() -> void:
	if state != State.PLAYING:
		return
	score += 1
	score_label.text = str(score)
	spawn_timer.wait_time = maxf(MIN_INTERVAL, BASE_INTERVAL - score * 0.02)
	update_background_scroll_speed()


func set_background_scroll(on: bool) -> void:
	for layer: Parallax2D in layer_speeds:
		layer.autoscroll = layer_speeds[layer] if on else Vector2.ZERO


func update_background_scroll_speed() -> void:
	var factor := minf(BASE_SPEED + score * 4.0, MAX_SPEED) / BASE_SPEED
	for layer: Parallax2D in layer_speeds:
		layer.autoscroll = layer_speeds[layer] * factor


func spawn_bone() -> void:
	var bone: Bone = BONE_SCENE.instantiate()
	bone.position = Vector2(BONE_SPAWN_X, randf_range(GAP_CENTER_MIN, GAP_CENTER_MAX))
	bone.speed = minf(BASE_SPEED + score * 4.0, MAX_SPEED)
	bone.hit.connect(game_over)
	bone.scored.connect(_on_bone_scored)
	bones.add_child(bone)
