extends Node2D

## The current phase of the game loop.
enum State {
	## Waiting for the first tap. The player hovers and no pipes spawn.
	READY,
	## The player is flying, pipes are spawning, and taps flap.
	PLAYING,
	## The run has ended. Taps restart the game once `can_restart` is true.
	GAME_OVER,
}

const PIPE_SCENE: PackedScene = preload("res://scenes/pipe.tscn")
const PIPE_SPAWN_X := 540.0
const GAP_CENTER_MIN := 180.0
const GAP_CENTER_MAX := 570.0

## Which phase the game is in. Changed only by `start_game()` and `game_over()`.
var state: State = State.READY
var can_restart := false
var score := 0

## The player. Used to flap, start, and kill it, and to listen for its `crashed` signal.
@onready var player: Player = $Player
@onready var message_label: Label = $UI/MessageLabel
@onready var score_label: Label = $UI/ScoreLabel
@onready var pipes: Node2D = $Pipes
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	player.crashed.connect(game_over)
	message_label.text = "Tap or press Space to start"
	spawn_timer.timeout.connect(spawn_pipe)

func _input(event: InputEvent) -> void:
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
	spawn_pipe()
	spawn_timer.start()

func game_over() -> void:
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER
	spawn_timer.stop()
	get_tree().call_group("pipes", "set_physics_process", false)
	player.die()
	message_label.text = "Game Over\nTap to restart"
	message_label.show()
	await get_tree().create_timer(0.6).timeout
	can_restart = true
	
func _on_pipe_scored() -> void:
	if state != State.PLAYING:
		return
	score += 1
	score_label.text = str(score)
	
func spawn_pipe() -> void:
	var pipe: Pipe = PIPE_SCENE.instantiate()
	pipe.position = Vector2(PIPE_SPAWN_X, randf_range(GAP_CENTER_MIN, GAP_CENTER_MAX))
	pipe.hit.connect(game_over)
	pipe.scored.connect(_on_pipe_scored)
	pipes.add_child(pipe)
