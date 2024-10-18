class_name Player
extends Node

var controller: GameController
var board: Board:
	get:
		return controller.board

var player_type: Player.PlayerType
var network_id: int
var game_id: Player.PlayerID
var friendly: Array[Player] = [self]
var actions_remaining: int = 0

var can_move: bool:
	get:
		return actions_remaining > 0

var init_state: GameSetup.PlayerState
var pieces: Array[ChessPiece] = []

func _init():
	pass
	
enum PlayerID {
	Player1,
	Player2,
	Player3,
	Player4,
}

enum PlayerType {
	None,
	Human,
	AI,
}
