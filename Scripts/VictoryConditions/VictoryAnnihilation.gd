class_name VictoryAnnihilation
extends VictoryCondition


func evaluate_victory(state: BoardBase.BoardState, rules: BoardBase.GameSettings) -> Array[int]:
	return _elimination_victory(state)

func evaluate_defeat(state: BoardBase.BoardState, rules: BoardBase.GameSettings) -> Array[int]:
	for p in state.players:
		if defeated.has(p.id):
			continue
		if p.pieces.size() == 0:
			defeated.append(p.id)
	return defeated
