extends Node

var prefabs: Dictionary = {}
var prefabs_filled = false

func fill_prefabs():
	var dir = DirAccess.open("res://Prefabs")
	_parse_directory(dir)
	prefabs_filled = true

		
func _parse_directory(dir: DirAccess):
	var files := dir.get_files()
	for file in files:
		var parts = file.split(".")
		if parts[1] == "tscn":
			prefabs[parts[0]] = load(dir.get_current_dir() + "/" + file)
	var folders = dir.get_directories()
	for folder in folders:
		_parse_directory(DirAccess.open(dir.get_current_dir() + "/" + folder))
	
func get_prefab(path: String) -> PackedScene:
	if not prefabs_filled:
		fill_prefabs()
	return prefabs[path]
