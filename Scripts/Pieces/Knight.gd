extends ChessPiece

func _get_actions() -> Array[GameController.GameAction]:
	var target_positions = [
		pos + Vector2i(1, 2),
		pos + Vector2i(2, 1),
		pos + Vector2i(1, -2),
		pos + Vector2i(2, -1),
		pos + Vector2i(-1, 2),
		pos + Vector2i(-2, 1),
		pos + Vector2i(-1, -2),
		pos + Vector2i(-2, -1),
	]
	var actions: Array[GameController.GameAction] = []
	
	for target_pos in target_positions:
		var act = _act_on_cell(target_pos)
		if act != null:
			actions.append(act)
	return actions
