class_name PressButton
extends Node

@export
var to_move: Array[Node3D]
@export
var move_distance: Vector3

@onready
var area_press: Area3D = $PressArea
@onready
var sound_down: FmodEventEmitter3D = $SoundDown
@onready
var sound_up: FmodEventEmitter3D = $SoundUp

var _pressed: bool = false

signal on_pressed
signal on_depressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_press.input_event.connect(_input_event)
	area_press.mouse_exited.connect(depress)

func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int):
	if not event.is_action("LMB"):
		return
	if event.is_pressed():
		press()
	else:
		depress()
		
func press():
	if _pressed:
		return
	_pressed = true
	sound_down.play()
	on_pressed.emit()
	for node in to_move:
		node.position += move_distance

func depress():
	if not _pressed:
		return
	_pressed = false
	sound_up.play()
	on_depressed.emit()
	for node in to_move:
		node.position -= move_distance
