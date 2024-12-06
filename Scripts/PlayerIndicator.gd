extends MeshInstance3D

@export var game_id: int
@onready var light: OmniLight3D = $OmniLight3D
@onready var mesh_instance: MeshInstance3D = self
@onready var power_coordinator: PowerCoordinator = $PowerCoordinator

static var indicator_green: Array[Color] = [Color.hex(0x22ff00ff), Color.hex(0x22aa22ff)]
static var indicator_red: Array[Color] = [Color.hex(0xff5500ff), Color.hex(0xaa2222ff)]
static var indicator_off: Array[Color] = [Color(), Color.hex(0x333333ff)]

static var IndicatorColor: Dictionary = {
	"Green": indicator_green,
	"Red": indicator_red,
	"Off": indicator_off,
}

func _ready():
	set_indicator(IndicatorColor["Green"])
	
func _process(_delta):
	var p = GameController.players_by_game_id.get(game_id, null)
	
	if not power_coordinator.on or not GameController.game_in_progress or p == null or p.defeated:
		set_indicator(IndicatorColor["Off"])
	elif p.can_move:
		set_indicator(IndicatorColor["Green"])
	else:
		set_indicator(IndicatorColor["Red"])

func set_indicator(color: Array[Color]):
	var l = color[0]
	var m = color[1]
	light.light_color = l
	var material: Material = mesh_instance.get_active_material(0).duplicate()
	material.albedo_color = m
	if l == Color():
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		
	mesh_instance.set_surface_override_material(0, material)
