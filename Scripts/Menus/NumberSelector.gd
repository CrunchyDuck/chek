extends Control

@export
var increment_amount: int = 1
@export
var number: int = 1

@onready
var left_arrow: Button = $LeftArrow
@onready
var number_label: Label = $Number
@onready
var right_arrow: Button = $RightArrow

func _ready():
	left_arrow.pressed.connect(decrement)
	right_arrow.pressed.connect(increment)
	number_label.text = str(number)

func decrement():
	number = max(number - increment_amount, 0)
	number_label.text = str(number)

func increment():
	number = number + increment_amount
	number_label.text = str(number)
