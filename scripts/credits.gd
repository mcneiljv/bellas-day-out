extends Node

const MENU_SCENE = "res://scenes/menu.tscn"

@onready var back_button: Button = $BackButton


func _ready() -> void:
	back_button.pressed.connect(_go_to_menu)


func _go_to_menu():
	get_tree().change_scene_to_file(MENU_SCENE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_go_to_menu()
		return
