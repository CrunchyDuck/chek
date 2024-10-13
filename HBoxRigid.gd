@tool

class_name HBoxRigid
extends HBoxContainer

@export var fixed_width: float = 50

func _process(delta: float):
	var children := get_children()
	for child in children:
		if not child is Control:
			continue
		child.custom_minimum_size.x = fixed_width
		child.size.x = fixed_width
