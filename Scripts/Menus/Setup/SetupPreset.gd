class_name SetupPreset
extends Node

const presets_path: String = "res://BoardPresets"
var presets: Array[BoardBase.GamePreset] = []

@onready
var node_preset_list: VBoxContainer = $PresetsViewport/PresetList

func _ready():
	read_presets()
	create_entries()

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
		
	for p in presets:
		create_entry(p)
	
func create_entry(preset: BoardBase.GamePreset):
	var p = PrefabController.get_prefab("Menus.Setup.PresetEntry").instantiate()
	p.get_node("Fields/Name").text = preset.name
	p.get_node("Fields/Player").text = str(preset.players)
	p.get_node("Fields/Complexity").text = str(preset.complexity)
	p.get_node("Button").pressed.connect(func (): set_preset(preset))
	node_preset_list.add_child(p)

func set_preset(preset: BoardBase.GamePreset):
	# TODO: Highlight currently selected prefab.
	# TODO: Remove prefab highlight when any change happens
	print("here")
	pass
