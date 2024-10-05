class_name Player
extends Node

var controller: GameController
var board: Board:
  get:
    return controller.board

var id: Player.PlayerID
var friendly: Array[Player] = [self]
var actions_remaining: int = 0

var can_move: bool:
  get:
    return actions_remaining > 0

var init_state: Board.PlayerState
var pieces: Array[ChessPiece] = []

func _init(id: Player.PlayerID, controller: GameController):
  self.id = id
  self.controller = controller

enum PlayerID {
  Player1,
  Player2,
  Player3,
  Player4,
}
