extends CanvasLayer

@onready
var rect: ColorRect = $ColorRect

func _ready() -> void:
	ColorControllers.palette_updated.connect(refresh_palette)
	refresh_palette()

func refresh_palette():
	rect.material.set_shader_parameter("palette", ColorControllers.current_palette)
