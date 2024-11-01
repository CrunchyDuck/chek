@tool

class_name VBoxRigid
extends VBoxContainer

var _height: float:
	get:
		if fixed_height > 0:
			return fixed_height
		if fixed_elements > 0:
			return self.custom_minimum_size.y / float(fixed_elements)
		return size.y
@export var fixed_height: float = 0
@export var fixed_elements: int = 0

func _process(delta: float):
	self.size = custom_minimum_size
	var children := get_children()
	for child in children:
		if not child is Control:
			continue
		child.custom_minimum_size.y = _height
		child.size.y = _height
		child.size.x = self.custom_minimum_size.x
		child.custom_minimum_size.x = self.custom_minimum_size.x
