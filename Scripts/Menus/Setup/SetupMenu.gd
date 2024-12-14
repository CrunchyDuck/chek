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
var button_start: Button = $VBoxContainer/Start

var scene_preset: Node
var scene_rules: Node
var scene_board: Node

var settings: GameSettings:
	get:
		return GameController.game_settings
	set(value):
		GameController.game_settings = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_preset = PrefabController.get_prefab("Menus.Setup.Preset").instantiate()
	scene_rules = PrefabController.get_prefab("Menus.Setup.Rule").instantiate()
	scene_board = PrefabController.get_prefab("Menus.Setup.Board").instantiate()
	
	node_content.add_child(scene_preset)
	node_content.add_child(scene_rules)
	node_content.add_child(scene_board)
	
	# I don't register these, so that it doesn't force them to spawn before they're ready.
	#if multiplayer.is_server():
		#PrefabController.register_networked_node.rpc("Menus.Setup.Prefab", scene_preset.get_path())
		#PrefabController.register_networked_node.rpc("Menus.Setup.Rule", scene_rules.get_path())
		#PrefabController.register_networked_node.rpc("Menus.Setup.Board", scene_board.get_path())
	
	button_preset.pressed.connect(func(): _load_scene(scene_preset))
	button_rule.pressed.connect(func(): _load_scene(scene_rules))
	button_board.pressed.connect(func(): _load_scene(scene_board))
	if multiplayer.is_server():
		button_start.pressed.connect(_on_start)
	else:
		button_start.disabled = true
	
	_load_scene(scene_preset)

func _load_scene(scene: Node):
	for c in node_content.get_children():
		Helpers.disable_node(c)
	Helpers.enable_node(scene)

func _on_start():
	if not GameController.can_start_game():
		return
	GameController.server_start_game()
