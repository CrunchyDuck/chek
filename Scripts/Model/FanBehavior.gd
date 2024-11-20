class_name FanBehavior
extends Node3D

@onready
var node_off_area: Area3D = $OffArea
@onready
var node_on_area: Area3D = $OnArea

@onready
var node_button: Node3D = $Button
var button_rotation: float = 8

var on: bool: 
	get: 
		return self_on and console_on
var self_on: bool = true
var console_on: bool = false
var fan_running: bool = false

@onready
var fan_sound: FmodEventEmitter3D = $Sound
var last_on: float = 0
var sound_target: float = 0
var settle_volume: float = 0.1
var settle_time: float = 20
var fade_speed = 0.2
var on_delay = 1

func _ready() -> void:
	node_off_area.input_event.connect(_off)
	node_on_area.input_event.connect(_on)
	$"../Lever".switched_on.connect(func (): console_switch(true))
	$"../Lever".switched_off.connect(func (): console_switch(false))
	fan_sound.volume = 0
	
func _process(delta: float) -> void:
	if fan_running:
		var time_on = (Time.get_ticks_msec() / 1000.0) - last_on
		var t = clamp(time_on / settle_time, 0, 1)
		sound_target = lerpf(settle_volume, 1, 1 - t)
	else:
		sound_target = 0
	fan_sound.volume = move_toward(fan_sound.volume, sound_target, fade_speed * delta)
	if fan_sound.volume == 0:
		fan_running = false
		fan_sound.stop()
		
func console_switch(state):
	console_on = state
	if on:
		await get_tree().create_timer(on_delay).timeout
	update_sound()
	
func update_sound():
	if on:
		last_on = Time.get_ticks_msec() / 1000
		if fan_sound.volume == 0:
			fan_running = true
			fan_sound.volume = 1
			fan_sound.play()
	else:
		fan_running = false

func _off(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not event.is_action_pressed("LMB"):
		return
	node_button.rotation_degrees.x = -button_rotation
	self_on = false
	update_sound()
	
func _on(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not event.is_action_pressed("LMB"):
		return
	node_button.rotation_degrees.x = button_rotation
	self_on = true
	update_sound()
