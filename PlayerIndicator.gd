extends MeshInstance3D

@onready var light: OmniLight3D = $Light

static var color_green: Color = Color.hex(0x22ff00)
static var color_red: Color = Color.hex(0xff5500)

func set_indicator(color: Color):
  light.light_color = color
  # TODO: Set mesh to same colour.
