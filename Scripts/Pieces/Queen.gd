extends ChessPiece

func _get_actions() -> Array[Board.GameAction]:
	var actions: Array[Board.GameAction] = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			actions += _act_in_line(Vector2i(x, y))
	return actions
