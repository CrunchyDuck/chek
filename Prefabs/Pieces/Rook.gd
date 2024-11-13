extends ChessPiece

func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	actions += _act_in_line(Vector2i(0, 1))
	actions += _act_in_line(Vector2i(0, -1))
	actions += _act_in_line(Vector2i(1, 0))
	actions += _act_in_line(Vector2i(-1, 0))
	return actions
