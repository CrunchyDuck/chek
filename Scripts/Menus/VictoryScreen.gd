extends Node

@onready
var button_return: Button = $CenterContainer/VBoxContainer/Button

func _ready() -> void:
	button_return.pressed.connect(_on_return)
	
func _on_return():
	pass
