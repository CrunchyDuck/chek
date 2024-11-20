class_name FanBehavior
extends Node3D

@onready
var node_off_area: Area3D = $OffArea
@onready
var node_on_area: Area3D = $OnArea
@onready
var node_button: Node3D = $Button

@onready
var sound_fan: FmodEventEmitter3D = $SoundRunning
@onready
var sound_switch: FmodEventEmitter3D = $SoundSwitch

var button_rotation: float = 8

var on: bool: 
  get: 
    return self_on and console_on
var self_on: bool = true
var console_on: bool = false
var fan_running: bool = false

var last_on: float = 0
var sound_target: float = 0
var settle_volume: float = 0.1
var settle_time: float = 20
var fade_speed: float:
  get:
    return 0.2 if on else 0.5
var on_delay = 1

func _ready() -> void:
  node_off_area.input_event.connect(_off)
  node_on_area.input_event.connect(_on)
  $"../Lever".switched_on.connect(func (): console_switch(true))
  $"../Lever".switched_off.connect(func (): console_switch(false))
  sound_fan.volume = 0
  
func _process(delta: float) -> void:
  if fan_running:
    var time_on = (Time.get_ticks_msec() / 1000.0) - last_on
    var t = clamp(time_on / settle_time, 0, 1)
    sound_target = lerpf(settle_volume, 1, 1 - t)
  else:
    sound_target = 0
    
  sound_fan.volume = move_toward(sound_fan.volume, sound_target, fade_speed * delta)
  if sound_fan.volume == 0:
    fan_running = false
    sound_fan.stop()
    
func console_switch(state):
  console_on = state
  if on:
    await get_tree().create_timer(on_delay).timeout
  update_sound()
  
func update_sound():
  if on:
    last_on = Time.get_ticks_msec() / 1000
    if sound_fan.volume == 0:
      fan_running = true
      sound_fan.volume = 1
      sound_fan.play()
  else:
    fan_running = false

# TODO: Fan switch sounds
func _off(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
  if not event.is_action_pressed("LMB") or not self_on:
    return
  sound_switch.stop()
  sound_switch.play()
  node_button.rotation_degrees.x = -button_rotation
  self_on = false
  update_sound()
  
func _on(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
  if not event.is_action_pressed("LMB") or self_on:
    return
  sound_switch.stop()
  sound_switch.play()
  node_button.rotation_degrees.x = button_rotation
  self_on = true
  update_sound()
