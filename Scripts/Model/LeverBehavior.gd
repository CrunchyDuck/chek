extends Node3D

@onready
var node_handle: Node3D = $Handle
@onready
var node_arms: Node3D = $Arms
@onready
var node_pivot: Node3D = $Pivot

@onready
var node_click_area: Area3D = $ClickArea

@onready
var node_on_off_light: OmniLight3D
@onready
var node_console: Node3D = $".."


# Grabbing and pulling lever
var on = false
var tripping = false
var being_held: bool = false
var mouse_pull: float = 0  # Where the mouse is trying to pull the lever
var lever_rest_position: float:
  get:
    return 180 if on else 0
var lever_rotation: float = 0  # The lever's progress, before being slowed.
var lever_distance: float:
  get:
    return abs(lever_rest_position - lever_rotation)
var trip_distance: float = 50
var mouse_movement_to_rotation = 0.2

var lever_normal_speed: float = 100
var lever_trip_speed: float = 1200
var lever_speed: float:
  get:
    return lever_normal_speed if not tripping else lever_trip_speed

var on_time: float = 0
var delay_room_light: float = 2
var delay_screens: float = 1
var tripping_time = 1

@onready var sound_switch: FmodEventEmitter3D = $FlipSound
var sound_light_on

signal switched_on
signal switched_off

func _ready():
  node_click_area.input_event.connect(_mouse_input_event)

func turn_on():
  on = true
  switched_on.emit()
  await get_tree().create_timer(tripping_time).timeout
  tripping = false
  
func turn_off():
  on = false
  switched_off.emit()
  await get_tree().create_timer(tripping_time).timeout
  tripping = false

func _process(delta: float) -> void:
  var lever_rotation_target = lever_rest_position + mouse_pull
  lever_rotation = move_toward(lever_rotation, lever_rotation_target, lever_speed * delta)
  lever_rotation = clampf(lever_rotation, 0, 180)
  
  # Dampening
  var lever_final: float
  if tripping:
    lever_final = lever_rotation
  else:
    var t = lever_distance / trip_distance
    t = pow(t, 0.5)
    # Pull upwards
    if not on:
      lever_final = lerpf(0, trip_distance, t)
    # Pull downwards
    else:
      lever_final = lerpf(180, 180 - trip_distance, t)
  
  try_trip()
  node_arms.rotation_degrees.x = -lever_final
  node_pivot.rotation_degrees.x = -lever_final
  node_handle.rotation_degrees.x = -lever_final

func try_trip():
  if tripping or lever_distance < trip_distance:
    return
    
  being_held = false
  mouse_pull = 0
  tripping = true
  sound_switch.play()
  if on:
    turn_off()
  else:
    turn_on()

func _input(event):
  if not Input.is_action_pressed("LMB"):
    being_held = false
    mouse_pull = 0
  if being_held and event is InputEventMouseMotion:
    mouse_pull += event.relative.y * mouse_movement_to_rotation

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
  if Input.is_action_just_pressed("LMB"):
    mouse_pull = 0
    being_held = true
