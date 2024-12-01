class_name SetupPreset
extends Node

const presets_path: String = "res://BoardPresets"
var presets: Array[BoardBase.GamePreset] = []

var buttons: Dictionary = {}

@onready
var node_preset_list: VBoxContainer = $PresetsViewport/PresetList

@onready
var stylebox_selected: StyleBoxFlat = load("res://Styles & Fonts/StyleboxPresetSelected.tres")

var _selected_button: Button

func _ready():
	stylebox_selected.bg_color = ColorController.preset_button_selected_color
	read_presets()
	create_entries()
	update_buttons_clickable()
	GameController.on_board_state_changed.connect(func (s): select_button(null))
	GameController.on_game_settings_changed.connect(func (s): select_button(null))
	set_preset(presets[0])

func read_presets():
	presets = []
	var dir = DirAccess.open(presets_path)
	
	var files = dir.get_files()
	for file in files:
		var f = FileAccess.get_file_as_string(presets_path + "/" + file)
		var j = JSON.parse_string(f)
		var gp = BoardBase.GamePreset.deserialize(j)
		presets.append(gp)

func create_entries():
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
	p.get_node("Button").pressed.connect(func (): set_preset(preset))
	node_preset_list.add_child(p)
	buttons[preset] = p.get_node("Button")

func set_preset(preset: BoardBase.GamePreset):
	GameController.board_state = preset.board_state
	GameController.game_settings = preset.game_settings
	select_button(buttons[preset])
	# TODO: Synchronize which prefab is selected across users.

func select_button(button: Button):
	if _selected_button:
		_selected_button.remove_theme_stylebox_override("normal")
		_selected_button.remove_theme_stylebox_override("focus")
		_selected_button.remove_theme_stylebox_override("hover_pressed")
		_selected_button.remove_theme_stylebox_override("hover")
		_selected_button.remove_theme_stylebox_override("pressed")
		
	if button == null:
		return
		
	_selected_button = button
	_selected_button.add_theme_stylebox_override("normal", stylebox_selected)
	_selected_button.add_theme_stylebox_override("focus", stylebox_selected)
	_selected_button.add_theme_stylebox_override("hover_pressed", stylebox_selected)
	_selected_button.add_theme_stylebox_override("hover", stylebox_selected)
	_selected_button.add_theme_stylebox_override("pressed", stylebox_selected)

func update_buttons_clickable():
	var state = false
	if multiplayer.is_server():
		state = true
	else:
		state = GameController.game_settings.can_players_edit
		
	for button in buttons.values():
		button.disabled = !state
