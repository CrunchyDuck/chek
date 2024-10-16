@tool

class_name VBoxRigid
extends VBoxContainer

var _height: float:
	get:
		if fixed_height > 0:
			return fixed_height
		return self.custom_minimum_size.y / float(fixed_elements)
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


func _on_button_pressed() -> void:
	pass # Replace with function body.
