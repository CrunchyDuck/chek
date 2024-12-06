extends Node

@export
var target: MeshInstance3D
@export
var unlit_texture: StandardMaterial3D
@export
var lit_texture: StandardMaterial3D
@export
var material_index: int

var lit: bool = false

func toggle_power(state: bool):
	if target == null:
		return
	if state:
		lit = true
		target.set_surface_override_material(material_index, lit_texture)
	else:
		lit = false
		target.set_surface_override_material(material_index, unlit_texture)

func change_lit_texture(new_texture: StandardMaterial3D):
	lit_texture = new_texture
	toggle_power(lit)

func change_unlit_texture(new_texture: StandardMaterial3D):
	unlit_texture = new_texture
	toggle_power(lit)
