extends ChessPiece

var piece_description = ColorControllers.color_text("Self destructive vendetta.\n", ColorControllers.description_color)\
+ "Move and take cardinals."

func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	actions += _act_in_line(Vector2i(0, 1))
	actions += _act_in_line(Vector2i(0, -1))
	actions += _act_in_line(Vector2i(1, 0))
	actions += _act_in_line(Vector2i(-1, 0))
	return actions
