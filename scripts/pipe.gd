class_name Pipe
extends Node2D

signal hit
signal scored

@export var speed: float = 200.0

func _ready() -> void:
	add_to_group("pipes")
	$TopPipe.body_entered.connect(_on_hazard_body_entered)
	$BottomPipe.body_entered.connect(_on_hazard_body_entered)
	$ScoreZone.body_entered.connect(_on_score_zone_body_entered)

func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -100.0:
		queue_free()

# NOTE: _body never used
func _on_hazard_body_entered(_body: Node2D) -> void:
	hit.emit()

# NOTE: _body never used
func _on_score_zone_body_entered(_body: Node2D) -> void:
	scored.emit()
