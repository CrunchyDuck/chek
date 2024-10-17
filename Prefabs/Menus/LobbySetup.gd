extends Control

@onready
var button_start: Button = $Start

func _ready() -> void:
	button_start.pressed.connect(_on_start)
	if not multiplayer.is_server():
		button_start.disabled = true
	
func _on_start():
	# TODO: Load board.
	pass
