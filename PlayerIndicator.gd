extends MeshInstance3D

@onready var light: OmniLight3D = $Light
@onready var mesh_instance: MeshInstance3D = self

static var color_green: Color = Color.hex(0x22ff00ff)
static var color_red: Color = Color.hex(0xff5500ff)

func _ready():
  set_indicator(color_green)

func set_indicator(color: Color):
  light.light_color = color
  var material = mesh_instance.get_active_material(0)
  material.albedo_color = color
  mesh_instance.set_surface_override_material(0, material)
