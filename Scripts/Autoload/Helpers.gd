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

static func disable_node(node: Node):
	node.process_mode = Node.PROCESS_MODE_DISABLED
	if node.has_method("hide"):
		node.hide()
	if node.has_method("on_disable"):
		node.on_disable()

static func enable_node(node: Node):
	node.process_mode = Node.PROCESS_MODE_INHERIT
	if node.has_method("show"):
		node.show()
	if node.has_method("on_enable"):
		node.on_enable()
