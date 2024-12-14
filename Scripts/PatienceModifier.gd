class_name PatienceModifier
extends Node

var my_player: Player: 
	get:
		return GameController.player

func _init():
	GameController.on_turn_start.connect(_on_turn_start)
	GameController.on_turn_end.connect(_on_turn_end)
	GameController.on_game_end.connect(_on_game_end)
	MainScreenController.instance.skip_button.on_pressed.connect(_on_pressed)

func _on_turn_start(player: Player):
	if player == my_player:
		MainScreenController.instance.skip_power.set_self(true)
		
func _on_turn_end(player: Player):
	if player == my_player:
		MainScreenController.instance.skip_power.set_self(false)

func _on_game_end():
	MainScreenController.instance.skip_power.set_self(false)
	Helpers.destroy_node(self)

func _on_pressed():
	GameController.skip_turn.rpc()
