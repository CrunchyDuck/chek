class_name ScreenButton
extends Node

@export var direction: String
@export var animator: AnimationPlayer

var node_collider: Area3D:
  get:
    return $Area3D
var node_light: OmniLight3D:
  get:
    return $OmniLight3D

var _light_energy: float = 1

var _pressed: bool = false
signal on_pressed(button: ScreenButton)

func _ready():
  node_collider.input_event.connect(_mouse_input_event)
  node_collider.mouse_exited.connect(depress)
  
func _process(_delta: float) -> void:
  if on_pressed.get_connections().size() == 0:
    node_light.light_energy = 0
  else:
    node_light.light_energy = _light_energy
  
func _mouse_input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
  if event is InputEventMouseButton:
    if event.pressed:
      press()
    else:
      depress()
  
func press():
  if _pressed:
    return
  on_pressed.emit(self)
  animator.play(direction + "Press")
  _pressed = true
  # TODO: Play sound

func depress():
  if not _pressed:
    return
  animator.play(direction + "Depress")
  _pressed = false
  # TODO: Play sound
