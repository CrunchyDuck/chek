class_name SetupPreset
extends Node

const presets_path: String = "res://BoardPresets"
# string Name: BoardBase.GamePreset
var presets: Dictionary = {}

var buttons: Dictionary = {}


@onready
var node_preset_list: VBoxContainer = $PresetsViewport/PresetList

@onready
var stylebox_selected: StyleBoxFlat = load("res://Styles & Fonts/StyleboxPresetSelected.tres")

var _selected_button: Button
var _selected_preset: BoardBase.GamePreset

func _ready():
	stylebox_selected.bg_color = ColorController.preset_button_selected_color
	presets = {}
	create_entries(read_presets())
	if multiplayer.is_server():
		update_buttons_clickable(true)
	else:
		update_buttons_clickable(GameController.game_settings.can_players_edit)
	GameController.on_board_state_changed.connect(func (s): highlight_preset(null))
	GameController.on_game_settings_changed.connect(func (s): highlight_preset(null))
	GameController.on_game_settings_changed.connect(_on_game_settings_changed)
	
	var send = {}
	var default_preset = presets.get("UNINSPIRED", null)
	if default_preset != null:
		send = default_preset.serialize()
	set_preset(send)

func read_presets() -> Array[BoardBase.GamePreset]:
	var dir = DirAccess.open(presets_path)
	
	var ps: Array[BoardBase.GamePreset] = []
	var files = dir.get_files()
	for file in files:
		var f = FileAccess.get_file_as_string(presets_path + "/" + file)
		var j = JSON.parse_string(f)
		var gp = BoardBase.GamePreset.deserialize(j)
		ps.append(gp)
	return ps

func create_entries(presets: Array[BoardBase.GamePreset]):
	for n in node_preset_list.get_children():
		node_preset_list.remove_child(n)
	buttons = {}
		
	for p in presets:
		create_entry(p)
	
func create_entry(preset: BoardBase.GamePreset):
	var p = PrefabController.get_prefab("Menus.Setup.PresetEntry").instantiate()
	p.get_node("Fields/Name").text = preset.name
	p.get_node("Fields/Player").text = str(preset.players)
	p.get_node("Fields/Complexity").text = str(preset.complexity)
	p.get_node("Button").pressed.connect(func (): on_preset_button_pressed(preset.serialize()))
	node_preset_list.add_child(p)
	buttons[preset] = p.get_node("Button")
	presets[preset.name] = preset

func highlight_preset(preset: BoardBase.GamePreset):
	_selected_preset = preset
	
	if _selected_button:
		_selected_button.remove_theme_stylebox_override("normal")
		_selected_button.remove_theme_stylebox_override("focus")
		_selected_button.remove_theme_stylebox_override("hover_pressed")
		_selected_button.remove_theme_stylebox_override("hover")
		_selected_button.remove_theme_stylebox_override("pressed")
		_selected_button.remove_theme_stylebox_override("disabled")
		
	if _selected_preset == null:
		_selected_button = null
		return
		
	_selected_button = buttons[preset]
	_selected_button.add_theme_stylebox_override("normal", stylebox_selected)
	_selected_button.add_theme_stylebox_override("focus", stylebox_selected)
	_selected_button.add_theme_stylebox_override("hover_pressed", stylebox_selected)
	_selected_button.add_theme_stylebox_override("hover", stylebox_selected)
	_selected_button.add_theme_stylebox_override("pressed", stylebox_selected)
	_selected_button.add_theme_stylebox_override("disabled", stylebox_selected)

func update_buttons_clickable(enabled: bool):
	for button in buttons.values():
		button.disabled = !enabled

func _on_game_settings_changed(new_settings: BoardBase.GameSettings):
	if multiplayer.is_server():
		return
	update_buttons_clickable(new_settings.can_players_edit)

func on_preset_button_pressed(json_preset: Dictionary):
	if multiplayer.is_server():
		set_preset.rpc(json_preset)
	else:
		client_set_preset.rpc_id(1, json_preset)
	
@rpc("authority", "call_local", "reliable")
func set_preset(json_preset: Dictionary):
	print("here")
	
	if json_preset == {}:
		_selected_preset = null
		highlight_preset(null)
		return
	
	var preset = BoardBase.GamePreset.deserialize(json_preset)
	# We don't want this to change to false/true unless set so in the rules by the server
	preset.game_settings.can_players_edit = GameController.game_settings.can_players_edit
	GameController.board_state = preset.board_state
	GameController.game_settings = preset.game_settings
	
	# TODO: Test sending a preset to a client that doesn't have it
	if not presets.has(preset.name):
		create_entry(preset)
	var local_preset = presets[preset.name]
	highlight_preset(local_preset)

@rpc("any_peer", "call_remote", "reliable")
func client_set_preset(json_preset: Dictionary):
	if not multiplayer.is_server():
		return
	if not GameController.game_settings.can_players_edit:
		return
	set_preset.rpc(json_preset)
	
@rpc("any_peer", "call_remote", "reliable")
func request_set_preset():
	if not multiplayer.is_server():
		return
	var send = _selected_preset.serialize() if _selected_preset != null else {}
	set_preset.rpc_id(multiplayer.get_remote_sender_id(), send)

	
