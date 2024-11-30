class_name Helpers
extends Node

# Removes a node from the tree and then destroys it.
static func destroy_node(node: Node):
	if node == null:
		return
	var p = node.get_parent()
	if p:
		p.remove_child(node)
	node.queue_free()
