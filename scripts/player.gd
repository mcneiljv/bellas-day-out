class_name Player
extends CharacterBody2D

signal crashed

@export var gravity: float = 1600.0
@export var flap_velocity: float = -480.0
@export var max_fall_speed: float = 800.0
@export var death_hop_velocity: float = -300.0
@export var death_spin_time: float = 0.8

const OFFSCREEN_Y := 900.0

@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D

var started := false
var alive := true

func start() -> void:
	started = true

func flap() -> void:
	if alive:
		velocity.y = flap_velocity

func die() -> void:
	if not alive:
		return
	alive = false
	# set_deferred because die() can be triggered from inside a physics callback.
	collision_shape.set_deferred("disabled", true)
	velocity.y = death_hop_velocity

	var tween := create_tween()
	tween.tween_property(self, "rotation", TAU, death_spin_time)	

func _physics_process(delta: float) -> void:
	if not started:
		return

	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	move_and_slide()
	
	$Sprite2D.rotation = clampf(velocity.y / 900.0, -0.5, 1)

	if not alive:
		# Dead: skip the ceiling clamp and crash check, and vanish once off-screen.
		if position.y > OFFSCREEN_Y:
			hide()
			set_physics_process(false)
		return

	# Don't let the player escape through the top of the screen.
	if position.y < 0.0:
		position.y = 0.0
		velocity.y = maxf(velocity.y, 0.0)

	if is_on_floor():
		crashed.emit()
