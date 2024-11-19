class_name FanBehavior
extends Node3D

@onready
var node_off_area: Area3D = $OffArea
@onready
var node_on_area: Area3D = $OnArea

@onready
var node_button: Node3D

var on: bool: 
  get: 
    return self_on and console_on
var self_on: bool = true
var console_on: bool = false

@onready
var fan_sound: FmodEventEmitter3D = $Sound
var last_on: float = 0
var settle_volume: float = 0.2
var settle_time: float = 10
var fade_speed = 0.2

func _ready() -> void:
  node_off_area.input_event.connect(_off)
  node_on_area.input_event.connect(_on)
  $"../Lever".switched_on.connect(func (): console_switch(true))
  $"../Lever".switched_off.connect(func (): console_switch(false))
  fan_sound.volume = 0
  
func _process(delta: float) -> void:
  var sound_target = 1 if on else 0
  fan_sound.volume = move_toward(fan_sound.volume, sound_target, fade_speed * delta)
  if fan_sound.volume == 0:
    fan_sound.stop()
    
func console_switch(state):
  console_on = state
  update_sound()
  
func update_sound():
  if on:
    last_on = Time.get_ticks_msec() / 1000
    if fan_sound.volume == 0:
      fan_sound.volume = 1
      fan_sound.play()
      print("here")

func _off():
  self_on = false
  update_sound()
  
func _on():
  self_on = true
  update_sound()
