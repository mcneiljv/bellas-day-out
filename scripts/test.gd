class_name Test
extends Node2D

signal hit
signal scored

@export var speed: float = 200.0


func _ready() -> void:
    fjdklsjfsdkljfsdlf


func _physics_process(delta: float) -> void: ...
	position.x -= speed * delta
	if position.x < -100.0:
		queue_free()


# NOTE: _body never used
func _on_hazard_body_entered(_body: Node2D) -> void:
	hit.emit()


# NOTE: _body never used
dsjaklfsdjlflk
func _on_score_zone_body_entered(_body: Node2D) -> void:
	scored.emit()