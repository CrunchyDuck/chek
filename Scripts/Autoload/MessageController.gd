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
  var my_color: String = ColorControllers.colors["c1"].to_html()
  if multiplayer.get_peers().size() != 0:
    var id = GameController.players_by_net_id[multiplayer.get_unique_id()].game_id
    my_color = ColorControllers.colors["c" + str(id + 3)].to_html()
  var message_values = {
      "name_color": my_color,
      "name": GameController.character_name,
      "content": content,
      "content_color": ColorControllers.colors.secondary.to_html(),
    }
  var message = "[b][color={name_color}]{name}:[/color][/b] [color={content_color}]{content}[/color]"
  message = message.format(message_values)
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
  
