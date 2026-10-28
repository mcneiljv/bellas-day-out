extends Node

const MENU_SCENE = "res://scenes/menu.tscn"

@onready var back_button: Button = $BackButton


func _ready() -> void:
	back_button.pressed.connect(_back_button_pressed)


func _back_button_pressed():
	get_tree().change_scene_to_file(MENU_SCENE)
