class_name PowerCoordinator
extends Node

@export
var power_to: Node  # A script that has a toggle_power(bool) function
@export
var power_switch: PressButton
@export
var delay: float

var on: bool:
	get:
		return self_on and console_on
@export
var self_on: bool = false
var console_on: bool = false

var last_updated_state: bool = false

signal powered_off()
signal powered_on()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var power_lever: LeverBehavior = $"/root/MainScene/Console/Lever"
	power_lever.switched_on.connect(func (): set_console(true))
	power_lever.switched_off.connect(func (): set_console(false))
	
	if power_switch:
		power_switch.on_pressed.connect(func (): toggle_self())
	if power_to != null:
		power_to.toggle_power(on)

func set_console(state):
	console_on = state
	try_change_state()

func toggle_self():
	self_on = not self_on
	try_change_state()
	
func set_self(state):
	if state == self_on:
		return
	self_on = state
	try_change_state()

func try_change_state():
	if on == last_updated_state:
		return
	
	last_updated_state = on
	if on:
		# Perform delay.
		await get_tree().create_timer(delay).timeout
	
	if on:
		powered_on.emit()
	else:
		powered_off.emit()
	if power_to != null:
		power_to.toggle_power(on)
