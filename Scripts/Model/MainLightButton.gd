extends Node3D

@export
var power_coordinator: PowerCoordinator
@onready
var node_shaft: MeshInstance3D = $Shaft
@onready
var node_tip: MeshInstance3D = $Tip

@onready
var light: OmniLight3D = $"../../RoomLight"
@onready
var sound_blink_small: FmodEventEmitter3D = light.get_node("SoundSmallBlink")
@onready
var sound_blink_big: FmodEventEmitter3D = light.get_node("SoundBigBlink")

var light_brightness: float = 0.2
var light_on_time: float = 0.1
var blink_span_min: float = 0.1
var blink_span_max: float = 0.5
var blink_min: int = 3
var blink_max: int = 7

func _ready():
  var mat = node_shaft.get_active_material(0).duplicate()
  node_shaft.set_surface_override_material(0, mat)
  node_tip.set_surface_override_material(0, mat)

func _process(delta: float) -> void:
  toggle_glowing(power_coordinator.console_on)
  if not power_coordinator.on:
    light.light_energy = 0

func toggle_glowing(state):
  node_shaft.get_active_material(0).emission_enabled = state
  node_tip.get_active_material(0).emission_enabled = state

func toggle_power(state: bool):
  if not state:
    return
  
  var blink_count = randi_range(blink_min, blink_max)
  while power_coordinator.on:
    if blink_count <= 1:
      break
    blink_count -= 1
    
    sound_blink_small.play()
    light.light_energy = light_brightness
    await get_tree().create_timer(light_on_time).timeout
    light.light_energy = 0
    
    var wait_time = randf_range(blink_span_min, blink_span_max)
    await get_tree().create_timer(wait_time).timeout
  
  if power_coordinator.on:
    sound_blink_big.play()
    light.light_energy = light_brightness
