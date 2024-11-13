extends ChessPiece

func _get_actions() -> Array[BoardPlayable.GameAction]:
	var target_positions = [
		coordinates + Vector2i(1, 2),
		coordinates + Vector2i(2, 1),
		coordinates + Vector2i(1, -2),
		coordinates + Vector2i(2, -1),
		coordinates + Vector2i(-1, 2),
		coordinates + Vector2i(-2, 1),
		coordinates + Vector2i(-1, -2),
		coordinates + Vector2i(-2, -1),
	]
	var actions: Array[BoardPlayable.GameAction] = []
	
	for target_pos in target_positions:
		var act = _act_on_cell(target_pos)
		if act != null:
			actions.append(act)
	return actions
