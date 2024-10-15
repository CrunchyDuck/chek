@tool

class_name HBoxRigid
extends HBoxContainer

var _width: float:
	get:
		if fixed_width > 0:
			return fixed_width
		return self.custom_minimum_size.x / float(fixed_elements)
@export var fixed_width: float = 0
@export var fixed_elements: int = 0

func _process(delta: float):
	size = custom_minimum_size
	var children := get_children()
	for child in children:
		if not child is Control:
			continue
		child.custom_minimum_size.x = _width
		child.size.x = _width
		child.size.y = self.custom_minimum_size.y
		child.custom_minimum_size.y = self.custom_minimum_size.y
			
