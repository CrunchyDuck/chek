extends ChessPiece

var piece_description =\
ColorControllers.color_text("Loyal.\nPsychologically degraded.\n", ColorControllers.description_color)\
+ "Explodes, decimating its tile, killing surrounding units.\n"\
+ "Paralyse adjacent units."

func _init():
	piece_type = ePieces.Beast
	
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	actions += _act_in_line(Vector2i(0, 1), 2)
	actions += _act_in_line(Vector2i(0, -1), 2)
	actions += _act_in_line(Vector2i(1, 0), 2)
	actions += _act_in_line(Vector2i(-1, 0), 2)
	return actions
