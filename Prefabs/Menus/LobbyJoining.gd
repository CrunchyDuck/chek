extends Control


@onready
var info_page: Control = $CenterContainer
@onready
var connecting_page: Control = $CenterContainer2

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
	
	multiplayer.connection_failed.connect(_on_fail)
	multiplayer.connected_to_server.connect(_on_success)

func _on_back():
	if info_page.visible:
		$"..".add_child(PrefabController.get_prefab("Menus.Start").instantiate())
		queue_free()
		return
	info_page.visible = true
	connecting_page.visible = false
	multiplayer.multiplayer_peer = null
	
func _on_done():
	if not GameController.join_lobby(input_ip.text, int(input_port.text)):
		# TODO: Chat message detailing fail
		return
	connecting_page.visible = true
	info_page.visible = false
	print("connecting")
	
func _on_success():
	$"..".add_child(PrefabController.get_prefab("Menus.GameSetup").instantiate())
	queue_free()
	print("connected")
	
func _on_fail():
	connecting_page.visible = false
	info_page.visible = true
	print("failed to connect")
	# TODO: Print error in chat.
