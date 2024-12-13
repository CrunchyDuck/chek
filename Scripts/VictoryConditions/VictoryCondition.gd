class_name VictoryCondition

var defeated: Array[int] = []

func evaluate_victory(state: BoardBase.BoardState, rules: GameSettings) -> Array[int]:
	return []

func evaluate_defeat(state: BoardBase.BoardState, rules: GameSettings) -> Array[int]:
	return []

func _elimination_victory(state: BoardBase.BoardState) -> Array[int]:
	if defeated.size() != state.players.size() - 1:
		return []
	for p in state.players:
		if not defeated.has(p.id):
			return [p.id]
	return []
