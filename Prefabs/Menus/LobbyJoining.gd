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
	button_back.pressed.connect(_on_back)
	button_done.pressed.connect(_on_done)

func _on_back():
	$"..".add_child(PrefabController.get_prefab("Menus.Start").instantiate())
	queue_free()
	
func _on_done():
	# TODO: Join server
	pass
