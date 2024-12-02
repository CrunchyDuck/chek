extends Node

@onready
var button_return: Button = $CenterContainer/VBoxContainer/Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_return.pressed.connect(_on_return)
	
func _on_return():
	pass
	
class PlayerStats:
	var player_num: int = 0
	var pieces_killed: int = 0
	var pieces_lost: int = 0
	var turns_taken: int = 0
	var distance_moved: float = 0
	var average_turn_time: float = 0
	
	# useless stats, randomly chosen
	var mistakes: int = 0  # randomly chosen based on pieces lost
	var tricks_pulled: int = 0  # Randomly chosen based on pieces killed
	var lights_on: bool = false
	var ventilation_on: bool = false
	var times_turned_monitor_off: int = 0
	var competence: float = 0  # Factors in various stats arbitrarily.
	var happy: bool = false
	var cheated: bool = false
	
	
