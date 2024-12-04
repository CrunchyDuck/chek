class_name VictoryPieceCapture
extends VictoryCondition


func evaluate_victory(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	if defeated.size() != players.size() - 1:
		return []
	for p in players:
		if not defeated.has(p.game_id):
			return [p]
	return []
			

func evaluate_defeat(action: BoardPlayable.GameAction, state: BoardBase.BoardState, rules: BoardBase.GameSettings, players: Array[Player]) -> Array[int]:
	# TODO: Change various pieces to use GameController to perform their actions, so this can be updated properly.
	for p in players:
		
	return defeated
