class_name BoardCoordinates
extends Control

@onready
var numbers_container: Control = $Coordinates
var coordinates_size: Vector2:
	get:
		return BoardBase.coordinates_size

var direction: Vector2

func _ready():
	clip_contents = true

func create_coordinates(_count: int):
	for _n in numbers_container.get_children():
		Helpers.destroy_node(_n)
		
	for i in range(_count):
		_spawn_number(i)
	
func _spawn_number(_number: int):
	var _l = Label.new()
	numbers_container.add_child(_l)
	_l.text = str(_number)
	_l.size = coordinates_size	
	_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_l.position = coordinates_size * direction * _number

func scroll_to(scroll_number: int):
	numbers_container.position = direction * coordinates_size * -scroll_number
