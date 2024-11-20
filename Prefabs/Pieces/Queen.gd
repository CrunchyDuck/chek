extends ChessPiece

var piece_description = ColorControllers.color_text("Spirit of Motherland.\n", ColorControllers.description_color)\
+ "Move and take any direction, any distance."

func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			actions += _act_in_line(Vector2i(x, y))
	return actions
