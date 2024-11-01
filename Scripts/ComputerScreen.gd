# I don't like that I have to attach scripts and nodes to a 3D mode
# to get screen projection working the normal way.
# This allows me to set the projection target from the projector.
extends Node

@export var target_mesh: MeshInstance3D

func _ready():
	# Spawn Area3D & CollisionShape
	var m: PlaneMesh = target_mesh.mesh
	
	var box = BoxShape3D.new()
	box.size = Vector3(m.size.x, m.size.y, 0)
	
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = box
	
	var a = Area3D.new()
	a.add_child(collision_shape)
	
	target_mesh.add_child(a)
	
	# Change material to unshaded & albedo to SubViewPort
	var vp_text = ViewportTexture.new()
	vp_text.viewport_path = get_path()
	
	var mat: StandardMaterial3D = target_mesh.get_active_material(0)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_texture = vp_text
	
	# Apply & init ClickableScreen script
	target_mesh.set_script(load("res://Scripts/ClickableScreen.gd"))
	var cs = target_mesh.get_script() as ClickableScreen
	cs.node_viewport = self
	cs.node_area = a
	cs.node_quad = target_mesh
