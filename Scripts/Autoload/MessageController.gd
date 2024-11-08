extends Node

var node_chat_screen: Control:
	get:
		return $/root/MainScene/ViewportChatScreen/ChatScreen
var node_message_list: VBoxContainer: 
	get: 
		return node_chat_screen.get_node("VBoxContainer/Messages")
var node_input: LineEdit: 
	get: 
		return node_chat_screen.get_node("VBoxContainer/Input")

# TODO: When the player powers the PC on: add_message("SYSTEM BOOT")
# TODO: When the player logs in: add_message("POTENTATE: {name}")
func _ready():
	node_input.text_submitted.connect(_on_submit)
	
func _on_submit(new_text: String):
	var content = node_input.text
	node_input.clear()
	# TODO: Send to network
	add_message(content)
	
@rpc("authority", "call_local", "reliable", 1)
func add_message(message: String):
	var node_message = Label.new()
	node_message.text = message
	node_message_list.add_child(node_message)
	
