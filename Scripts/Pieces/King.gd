extends ChessPiece

func _get_actions() -> Array[Board.GameAction]:
	var actions: Array[Board.GameAction] = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			var act = _act_on_cell(pos + Vector2i(x, y))
			if act != null:
				actions.append(act)
	return actions
