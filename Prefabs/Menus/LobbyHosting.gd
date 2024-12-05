extends Control

@onready
var button_back: Button = $Back

@onready
var button_done: Button = $CenterContainer/VBoxContainer/Button
@onready
var input_ip: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit
@onready
var input_port: LineEdit = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit2

func _ready() -> void:
	# TODO: For some reason the back button doesn't work here.
	button_back.pressed.connect(_on_back)
	button_done.pressed.connect(_on_done)
	input_ip.editable = false
	if not GameController.public_ip.is_empty():
		input_ip.text = GameController.public_ip

func _on_back():
	MainScreenController.load_new_scene("Menus.Start")

	
func _on_done():
	if not GameController.start_lobby(int(input_port.text)):
		# TODO: Print error in chat
		return
	Helpers.destroy_node(self)
