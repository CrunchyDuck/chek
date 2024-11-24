extends Node

@export
var target: MeshInstance3D
@export
var unlit_texture: StandardMaterial3D
@export
var lit_texture: StandardMaterial3D
@export
var material_index: int

func toggle_power(state: bool):
  if state:
    target.set_surface_override_material(material_index, lit_texture)
  else:
    target.set_surface_override_material(material_index, unlit_texture)
