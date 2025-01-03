class_name MainScreenController
extends Node

static var instance: MainScreenController

@onready
var viewport: Viewport = $".."

@onready
var node_central_screen: Control = $"../MainScreen"

@onready
var up_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenUp/PressButton"
@onready
var right_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenRight/PressButton"
@onready
var down_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenDown/PressButton"
@onready
var left_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenLeft/PressButton"

@onready
var up_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenUp/PowerCoordinator"
@onready
var right_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenRight/PowerCoordinator"
@onready
var down_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenDown/PowerCoordinator"
@onready
var left_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/MainScreenLeft/PowerCoordinator"

@onready
var next_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainNextButton/PressButton"
@onready
var previous_button: PressButton = $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainPreviousButton/PressButton"
@onready
var next_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainNextButton/PowerCoordinator"
@onready
var previous_power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainPreviousButton/PowerCoordinator"

var next_palette_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainNextPalette/PressButton"
var previous_palette_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainPreviousPalette/PressButton"
var next_palette_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainNextPalette/PowerCoordinator"
var previous_palette_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainPreviousPalette/PowerCoordinator"

var skip_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainSkipButton/PressButton"
var skip_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainSkipButton/PowerCoordinator"

var zoom_in_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainZoomInButton/PressButton"
var zoom_in_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainZoomInButton/PowerCoordinator"

var zoom_out_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainZoomOutButton/PressButton"
var zoom_out_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainZoomOutButton/PowerCoordinator"

var stop_button: PressButton:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainStopText/PressButton"
var stop_power: PowerCoordinator:
	get:
		return $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainStopText/PowerCoordinator"

@onready
var power: PowerCoordinator = $"/root/MainScene/Console/front_panel/frame_screen_main/ScreenMainPower/PowerCoordinator"

var scene_list: Array[Node] = []
var scene_index: int = 0

func _init():
	instance = self

func _ready():
	previous_button.on_pressed.connect(_prev_scene)
	next_button.on_pressed.connect(_next_scene)
	$"/root/MainScene/Console/Lever".switched_off.connect(reset)
	reset()

static func load_new_scene(prefab_path: String) -> Node:
	for c in instance.scene_list:
		if c == null:
			continue
		Helpers.destroy_node(c)
	instance.scene_index = 0
	instance.scene_list = []
	return add_scene(prefab_path)

static func add_scene(prefab_path: String) -> Node:
	var p = PrefabController.get_prefab(prefab_path).instantiate()
	instance.node_central_screen.add_child(p)
	instance.scene_list.append(p)
	instance._update_lights()
	if instance.scene_list.size() != 1:
		Helpers.disable_node_tree(p)
	return p

func reset():
	for c in node_central_screen.get_children():
		Helpers.destroy_node(c)
	load_new_scene("Menus.Start")
	_update_lights()

func _update_lights():
	if scene_index != 0 and scene_list.size() > 1:
		previous_power.set_self(true)
	else:
		previous_power.set_self(false)
	
	if scene_index != scene_list.size() - 1:
		next_power.set_self(true)
	else:
		next_power.set_self(false)

# TODO: Disconnect the frame buttons when changing scene.
func _prev_scene():
	if scene_list.size() <= 1:
		return
	Helpers.disable_node_tree(scene_list[scene_index])
	scene_index = clampi(scene_index - 1, 0, scene_list.size() - 1)
	Helpers.enable_node_tree(scene_list[scene_index])
	_update_lights()

func _next_scene():
	if scene_list.size() <= 1:
		return
	Helpers.disable_node_tree(scene_list[scene_index])
	scene_index = clampi(scene_index + 1, 0, scene_list.size() - 1)
	Helpers.enable_node_tree(scene_list[scene_index])
	_update_lights()
	
