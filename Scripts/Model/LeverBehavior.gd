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


# Grabbing and pulling lever
var on = false
var tripping = false
var being_held: bool = false
var lever_rotation_target: float = 0
var lever_rotation: float = 0
var lever_actual: float = 0  # Where it is after being clamped
var lever_trip: float = 50
var mouse_movement_to_rotation = 0.2

var lever_normal_speed: float = 100
var lever_trip_speed: float = 1200
var lever_max_speed: float = lever_normal_speed

var delay_room_light: float = 2
var delay_screens: float = 1

var sound_switch
var sound_light_on
var sound_fan

func _ready():
  node_click_area.input_event.connect(_mouse_input_event)

func turn_on():
  on = true
  being_held = false
  tripping = true
  lever_max_speed = lever_trip_speed
  
func turn_off():
  on = false
  being_held = false
  tripping = true
  lever_max_speed = lever_trip_speed

func _process(delta: float) -> void:
  if not Input.is_action_pressed("LMB"):
    being_held = false
  if not being_held:
    if not on:
      lever_rotation_target = 0
    else:
      lever_rotation_target = 180
  
  lever_rotation_target = clampf(lever_rotation_target, 0, 180)
  # Trigger thresholds
  if not tripping:
    if not on and lever_rotation >= lever_trip:
      turn_on()
    elif on and lever_rotation <= 180 - lever_trip:
      turn_off()
      
  lever_rotation = move_toward(lever_rotation, lever_rotation_target, lever_max_speed * delta)
  lever_actual = lever_rotation
  if not tripping:
    if not on:
      var t = lever_rotation / lever_trip
      t = pow(t, 0.5)
      lever_actual = lerpf(0, lever_trip, t)
    else:
      var t = lever_rotation / (180 - lever_trip)
      t = pow(t, 0.5)
      lever_actual = lerpf(0, lever_trip, t) + 180
  node_arms.rotation_degrees.x = -lever_actual
  node_pivot.rotation_degrees.x = -lever_actual
  node_handle.rotation_degrees.x = -lever_actual

func _input(event):
  if being_held and event is InputEventMouseMotion:
    lever_rotation_target += event.relative.y * mouse_movement_to_rotation

func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
  if not tripping and Input.is_action_pressed("LMB"):
    being_held = true
