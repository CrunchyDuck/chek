@tool

class_name VBoxRigid
extends VBoxContainer

@export var fixed_height: float = 50

func _process(delta: float):
	var children := get_children()
	for child in children:
		if not child is Control:
			continue
		child.custom_minimum_size.y = fixed_height
		child.size.y = fixed_height
