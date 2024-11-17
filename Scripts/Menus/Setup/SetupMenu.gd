extends Node

@onready
var node_navigation: Control = $VBoxContainer/SetupNavigation
@onready
var button_preset: Button = node_navigation.get_node("Preset")
@onready
var button_rule: Button = node_navigation.get_node("Rule")
@onready
var button_board: Button = node_navigation.get_node("Board")

@onready
var node_content: Node = $VBoxContainer/Content
@onready
var button_start: Node = $VBoxContainer/Start


var settings: BoardBase.GameSettings:
  get:
    return GameController.game_settings
  set(value):
    GameController.game_settings = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  button_preset.pressed.connect(func(): _load_scene("Menus.Setup.Preset"))
  button_rule.pressed.connect(func(): _load_scene("Menus.Setup.Rule"))
  button_board.pressed.connect(func(): _load_scene("Menus.Setup.Board"))
  button_start.pressed.connect(_on_start)

func _load_scene(scene_name: String):
    for c in node_content.get_children():
      c.queue_free()
    node_content.add_child(PrefabController.get_prefab(scene_name).instantiate())

func _on_start():
  var jgs = settings.serialize()
  var jbs = GameController.standard_board_setup().serialize()
  GameController.start_game.rpc(jgs, jbs)
