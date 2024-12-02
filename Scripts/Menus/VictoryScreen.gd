extends Node

@onready
var button_return: Button = $CenterContainer/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_return.pressed.connect(_on_return)
	
func _on_return():
	pass
