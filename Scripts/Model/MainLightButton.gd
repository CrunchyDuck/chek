extends Node3D

@onready
var node_shaft: MeshInstance3D = $Shaft
@onready
var node_tip: MeshInstance3D = $Tip

@onready
var area_pressed: Area3D = $Area3D
@onready
var sound_button_down: FmodEventEmitter3D = $SoundButtonDown
@onready
var sound_button_up: FmodEventEmitter3D = $SoundButtonUp
var _pressed = false

@onready
var light: OmniLight3D = $"../../RoomLight"
@onready
var sound_blink_small: FmodEventEmitter3D = light.get_node("SoundSmallBlink")
@onready
var sound_blink_big: FmodEventEmitter3D = light.get_node("SoundBigBlink")

var on: bool:
  get:
    return self_on and console_on
var self_on = false
var console_on = false

var light_brightness: float = 0.2
var on_delay: float = 0.5
var light_on_time: float = 0.1
var blink_span_min: float = 0.1
var blink_span_max: float = 0.5
var blink_min: int = 3
var blink_max: int = 7

func _ready():
  var mat = node_shaft.get_active_material(0).duplicate()
  node_shaft.set_surface_override_material(0, mat)
  node_tip.set_surface_override_material(0, mat)
  toggle_glowing(false)
  
  area_pressed.input_event.connect(_input_event)
  area_pressed.mouse_exited.connect(depress)
  $"../Lever".switched_on.connect(func (): console_switch(true))
  $"../Lever".switched_off.connect(func (): console_switch(false))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  if not on:
    light.light_energy = 0

func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
  if not event.is_action("LMB"):
    return
  if event.is_pressed():
    press()
  else:
    depress()
  
func console_switch(state):
  console_on = state
  toggle_glowing(state)
  try_turn_on()

func toggle_glowing(state):
  node_shaft.get_active_material(0).emission_enabled = state
  node_tip.get_active_material(0).emission_enabled = state
  
func try_turn_on():
  if not on:
    return
  await get_tree().create_timer(on_delay).timeout
  
  var blink_count = randi_range(blink_min, blink_max)
  while on:
    if blink_count <= 1:
      break
    blink_count -= 1
    
    sound_blink_small.play()
    light.light_energy = light_brightness
    await get_tree().create_timer(light_on_time).timeout
    light.light_energy = 0
    
    var wait_time = randf_range(blink_span_min, blink_span_max)
    await get_tree().create_timer(wait_time).timeout
  
  if on:
    sound_blink_big.play()
    light.light_energy = light_brightness
  
func press():
  if _pressed:
    return
  self_on = not self_on
  try_turn_on()
  _pressed = true
  sound_button_down.play()

func depress():
  if not _pressed:
    return
  _pressed = false
  sound_button_down.play()
