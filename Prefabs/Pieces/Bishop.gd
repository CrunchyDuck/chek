extends ChessPiece

func _get_actions() -> Array[Board.GameAction]:
	var actions: Array[Board.GameAction] = []
	actions += _act_in_line(Vector2i(1, 1))
	actions += _act_in_line(Vector2i(1, -1))
	actions += _act_in_line(Vector2i(-1, 1))
	actions += _act_in_line(Vector2i(-1, -1))
	return actions
