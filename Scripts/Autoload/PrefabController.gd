extends Node

var prefabs: Dictionary = {}
var prefabs_filled = false

# A node that is networked must fulfil the following criteria:
# Its path in the node tree does not change
# It optionally has a do_synchronize function, which will package variables and call an RPC
var networked_nodes: Dictionary

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
			var f = load(dir.get_current_dir() + "/" + file)
			prefabs[".".join(path)] = f
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

func spawn_prefab(prefab_path: String, node_path: String) -> Node:
	var node_parts = node_path.split("/")
	var parent = get_node("/".join(node_parts.slice(0, -1)))
	if parent == null:
		print("Could not find node at path: " + node_path)
		return
	
	var p = get_prefab(prefab_path).instantiate()
	parent.add_child(p)
	p.name = node_parts[-1]
	return p

@rpc("authority", "call_local", "reliable")
func register_networked_node(prefab_path: String, node_path: String) -> void:
	networked_nodes[node_path] = prefab_path
	
	# Spawn if it does not exist already
	var p = get_node_or_null(node_path)
	if p == null:
		p = spawn_prefab(prefab_path, node_path)
	
	# Call synchronize
	if multiplayer.is_server():
		if p.has_method("do_synchronize"):
			p.do_synchronize()

@rpc("authority", "call_local", "reliable")
func remove_networked_node(node_path: String) -> void:
	var node: Node = get_node(node_path)
	networked_nodes.erase(node_path)
	Helpers.destroy_node(node)

@rpc("any_peer", "call_remote", "reliable")
func request_refresh():
	if not multiplayer.is_server():
		return
	refresh_networked_nodes.rpc_id(multiplayer.get_remote_sender_id(), networked_nodes)

# Re synchronize this client with the host.
@rpc("authority", "call_remote", "reliable")
func refresh_networked_nodes(servers_nodes: Dictionary):
	var old_nodes := networked_nodes.duplicate()
	networked_nodes = {}
	for k in servers_nodes.keys():
		var prefab_path = servers_nodes[k]
		if old_nodes.has(k):
			old_nodes.erase(k)
		else:
			register_networked_node(prefab_path, k)
			
		var obj = get_node(k)
		if obj.has_method("request_synchronize"):
			obj.request_synchronize.rpc_id(1)
	
	# Clear up stale objects
	for k in old_nodes.keys():
		var old_node = get_node(k)
		if old_node:
			Helpers.destroy_node(old_node)
