class_name RightScreenController
extends Node

@onready
var viewport: Viewport = $".."
@onready
var node_container: Control = $"../RightScreen"

@onready
var left_button: Array[PressButton] = [
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonLeft1/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonLeft2/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonLeft3/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonLeft4/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonLeft5/PressButton",
]
var left_button_power: Array[PowerCoordinator] = []

@onready
var right_button: Array[PressButton] = [
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonRight1/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonRight2/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonRight3/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonRight4/PressButton",
	$"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenButtonRight5/PressButton",
]
var right_button_power: Array[PowerCoordinator] = []

@onready
var power: PowerCoordinator = $"/root/MainScene/Console/right_panel/RightScreenFrame/RightScreenPower/PowerCoordinator"

func _ready():
	for b in right_button:
		right_button_power.append(b.get_node("../PowerCoordinator"))
	for b in left_button:
		left_button_power.append(b.get_node("../PowerCoordinator"))
	$"/root/MainScene/Console/Lever".switched_off.connect(_on_main_power_off)

func _on_main_power_off():
	for c in node_container.get_children():
		Helpers.destroy_node(c)
		
	for b in right_button_power:
		b.set_self(false)
	for b in left_button_power:
		b.set_self(false)
