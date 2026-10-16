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

## Which phase the game is in. Changed only by `start_game()` and `game_over()`.
var state: State = State.READY
var can_restart := false

## The player. Used to flap, start, and kill it, and to listen for its `crashed` signal.
@onready var player: Player = $Player
@onready var message_label: Label = $UI/MessageLabel

func _ready() -> void:
	player.crashed.connect(game_over)
	message_label.text = "Tap or press Space to start"


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


func game_over() -> void:
	if state == State.GAME_OVER:
		return
	state = State.GAME_OVER
	player.die()
	message_label.text = "Game Over\nTap to restart"
	message_label.show()
	await get_tree().create_timer(0.6).timeout
	can_restart = true
