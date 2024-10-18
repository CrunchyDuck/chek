extends Node

var prefabs: Dictionary = {}
var prefabs_filled = false

func fill_prefabs():
	var dir = DirAccess.open("res://Prefabs")
	_parse_directory(dir, [])
	prefabs_filled = true
		
func _parse_directory(dir: DirAccess, path: PackedStringArray):
	var files := dir.get_files()
	for file in files:
		var parts = file.split(".")
		if parts[1] == "tscn":
			path.append(parts[0])
			prefabs[".".join(path)] = load(dir.get_current_dir() + "/" + file)
			print(".".join(path))
			path.remove_at(path.size() - 1)
			
	var folders = dir.get_directories()
	for folder in folders:
		path.append(folder)
		_parse_directory(DirAccess.open(dir.get_current_dir() + "/" + folder), path)
		path.remove_at(path.size() - 1)
	
func get_prefab(path: String) -> PackedScene:
	if not prefabs_filled:
		fill_prefabs()
	return prefabs[path]

@rpc("any_peer", "call_local", "reliable")
func spawn_networked_node(prefab_path: String, node_path: String, node_name: String) -> void:
	var n = get_node(node_path)
	if n == null:
		print("Could not find node at path: " + node_path)
		return
	
	var p = get_prefab(prefab_path).instantiate()
	n.add_child(p)
	n.name = node_name
