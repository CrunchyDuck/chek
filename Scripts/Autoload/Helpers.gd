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
	if node.has_method("hide"):
		node.hide()
	if node.has_method("on_disable"):
		node.on_disable()
	node.process_mode = Node.PROCESS_MODE_DISABLED
	for child in node.get_children():
		disable_node(child)

static func enable_node(node: Node):
	if node.has_method("show"):
		node.show()
	if node.has_method("on_enable"):
		node.on_enable()
	node.process_mode = Node.PROCESS_MODE_INHERIT
	for child in node.get_children():
		enable_node(child)
