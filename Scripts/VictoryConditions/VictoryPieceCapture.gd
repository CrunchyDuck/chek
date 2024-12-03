class_name VictoryPieceCapture
extends VictoryCondition


func evaluate_victory(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	

func evaluate_defeat(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	for p in players:
		
	return defeated
