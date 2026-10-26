class_name Player
extends CharacterBody2D

signal crashed

@export var gravity: float = 1600.0
@export var flap_velocity: float = -480.0
@export var max_fall_speed: float = 800.0
@export var death_hop_velocity: float = -300.0
@export var death_spin_time: float = 0.8

const OFFSCREEN_MARGIN: float = 46.0  # extra pixels so the bird is fully hidden before vanishing
const TILT_SPEED_SCALE: float = 900.0  # vertical speed (px/s) that equals 1 radian of tilt
const MAX_TILT_UP: float = -0.5  # radians (about -29°): nose-up limit
const MAX_TILT_DOWN: float = 1.0  # radians (about 57°): nose-down limit

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionPolygon2D = $CollisionPolygon2D
@onready var jump_sound: AudioStreamPlayer2D = $Jump
@onready var hit_sound: AudioStreamPlayer2D = $Hit

var started := false
var alive := true


func start() -> void:
	started = true


func flap() -> void:
	if alive:
		velocity.y = flap_velocity
		jump_sound.play()


func die() -> void:
	if not alive:
		return
	alive = false
	hit_sound.play()
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

	sprite.rotation = clampf(velocity.y / TILT_SPEED_SCALE, MAX_TILT_UP, MAX_TILT_DOWN)
	collision_shape.rotation = clampf(velocity.y / TILT_SPEED_SCALE, MAX_TILT_UP, MAX_TILT_DOWN)

	if not alive:
		# Dead: skip the ceiling clamp and crash check, and vanish once off-screen.
		if position.y > get_viewport_rect().size.y + OFFSCREEN_MARGIN:
			hide()
			set_physics_process(false)
		return

	# Don't let the player escape through the top of the screen.
	if position.y < 0.0:
		position.y = 0.0
		velocity.y = maxf(velocity.y, 0.0)

	if is_on_floor():
		crashed.emit()
