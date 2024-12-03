class_name VictoryCondition
extends Node

var sacred_piece_type: ChessPiece.ePieces
var defeated: Array[int] = []

func initialize(sacred_piece_type: ChessPiece.ePieces):
	self.sacred_piece_type = sacred_piece_type

func evaluate_victory(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	return []

func evaluate_defeat(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	return []
