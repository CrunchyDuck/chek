class_name SetupPreset
extends Node

const presets_path: String = "res://BoardPresets"
var presets: Array[BoardBase.GamePreset] = []

func _ready():
	read_presets()

func read_presets():
	presets = []
	var dir = DirAccess.open(presets_path)
	
	var files = dir.get_files()
	for file in files:
		var f = FileAccess.open(presets_path + "/" + file, FileAccess.READ)
		var j = JSON.parse_string(f.get_line())
		var gp = BoardBase.GamePreset.deserialize(j)
		presets.append(gp)
