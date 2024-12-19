class_name VictoryCondition

func evaluate_victory(state: BoardBase.BoardState, rules: GameSettings) -> Array[int]:
	return []

func evaluate_defeat(state: BoardBase.BoardState, rules: GameSettings):
	return []

func _elimination_victory(state: BoardBase.BoardState) -> Array[int]:
	var undefeated: Array[int] = []
	for p in Player.players:
		if not p.defeated:
			undefeated.append(p)
	
	if undefeated.size() == 1:
		return undefeated
	# TODO: Handle all players defeated. 
	return []
