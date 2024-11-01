extends MeshInstance3D

@onready var light: OmniLight3D = $Light
@onready var mesh_instance: MeshInstance3D = self

static var indicator_green: Array[Color] = [Color.hex(0x22ff00ff), Color.hex(0x22ff00ff)]
static var indicator_red: Array[Color] = [Color.hex(0xff5500ff), Color.hex(0xff5500ff)]
static var indicator_off: Array[Color] = [Color(), Color.hex(0x595959ff)]

static var IndicatorColor: Dictionary = {
	"Green": indicator_green,
	"Red": indicator_red,
	"Off": indicator_off,
}

func _ready():
	set_indicator(IndicatorColor["Off"])

func set_indicator(color: Array[Color]):
	var l = color[0]
	var m = color[1]
	light.light_color = l
	var material = mesh_instance.get_active_material(0)
	material.albedo_color = m
	mesh_instance.set_surface_override_material(0, material)
