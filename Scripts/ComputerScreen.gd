# I don't like that I have to attach scripts and nodes to a 3D mode
# to get screen projection working the normal way.
# This allows me to set the projection target from the projector.
extends SubViewport

@export var target_mesh: MeshInstance3D
const pixels_to_meters: float = 0.001

func _ready():  
  if not target_mesh:
    return
  var box = BoxShape3D.new()
  box.size = Vector3(self.size.x * pixels_to_meters, self.size.y * pixels_to_meters, 0)
  
  var collision_shape = CollisionShape3D.new()
  collision_shape.shape = box
  
  var a = Area3D.new()
  a.add_child(collision_shape)
  
  target_mesh.add_child(a)
  
  # Change material to unshaded & albedo to SubViewPort
  var vp_text = get_texture()
  
  var mat: StandardMaterial3D = target_mesh.get_active_material(0).duplicate()
  mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  mat.albedo_texture = vp_text
  target_mesh.set_surface_override_material(0, mat)
  
  # Apply & init ClickableScreen script
  target_mesh.set_script(load("res://Scripts/ClickableScreen.gd"))
  target_mesh.node_viewport = self
  target_mesh.node_area = a
  target_mesh.node_quad = target_mesh
  target_mesh.screen_dimensions = Vector2(self.size.x * pixels_to_meters, self.size.y * pixels_to_meters)
