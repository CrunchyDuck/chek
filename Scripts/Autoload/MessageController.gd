extends Node

var node_chat_screen: Control:
  get:
    return $/root/MainScene/ViewportChatScreen/ChatScreen
var node_message_list: VBoxContainer: 
  get: 
    return node_chat_screen.get_node("Messages")
var node_input: LineEdit: 
  get: 
    return node_chat_screen.get_node("Input")

# TODO: Make it so that typing anywhere but another lineedit sends the input here
# TODO: When the player powers the PC on: add_message("SYSTEM BOOT")
# TODO: When the player logs in: add_message("POTENTATE: {name}")
func _ready():
  node_input.text_submitted.connect(_on_submit)
  
func _on_submit(new_text: String):
  var content = node_input.text
  node_input.clear()
  
  var name_tag = ColorControllers.color_by_player(GameController.character_name + ": ", GameController.game_id)
  var message = name_tag + content
  # Is there really no way to check if you're connected to a server??
  if multiplayer.get_peers().size() != 0:
    try_add_message.rpc_id(1, message)
  else:
    add_message(message)
  
@rpc("any_peer", "call_local", "reliable", 1)
func try_add_message(message: String):
  if not multiplayer.is_server():
    return
  if message.length() > 512:
    return
  add_message.rpc(message)
  
@rpc("authority", "call_local", "reliable", 1)
func add_message(message: String):
  var node_message = RichTextLabel.new()
  node_message.text = message
  node_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  node_message.scroll_active = false
  node_message.bbcode_enabled = true
  node_message.fit_content = true
  node_message_list.add_child(node_message)
  
