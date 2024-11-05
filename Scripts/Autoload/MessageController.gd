extends Node

var node_message_list: VBoxContainer: 
  get: 
    return $/root/MainScene/ViewportChatScreen/ChatScreen/VBoxContainer

func _ready():
  # TODO: When the player powers the PC on: add_message("SYSTEM BOOT")
  pass
  
@rpc("authority", "call_local", "reliable", 1)
func add_message(message: String):
  var node_message = Label.new()
  node_message.text = message
  node_message_list.add_child(node_message)
  
