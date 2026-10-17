class_name Player
extends CharacterBody2D

signal crashed

@export var gravity: float = 1600.0
@export var flap_velocity: float = -480.0
@export var max_fall_speed: float = 800.0

var started := false
var alive := true

func start() -> void:
	started = true

func flap() -> void:
	if alive:
		velocity.y = flap_velocity

func die() -> void:
	alive = false

func _physics_process(delta: float) -> void:
	if not started:
		return

	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	move_and_slide()
	$Sprite2D.rotation = clampf(velocity.y / 900.0, -0.5, 1)

	# Don't let the player escape through the top of the screen.
	if position.y < 0.0:
		position.y = 0.0
		velocity.y = maxf(velocity.y, 0.0)

	if is_on_floor():
		crashed.emit()
