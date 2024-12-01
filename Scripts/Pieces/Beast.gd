extends ChessPiece

var piece_description =\
ColorControllers.color_text("The blood spills.\nThe ground quakes.\n", ColorControllers.description_color)\
+ "Move and attack cardinals up to 2.\n"\
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

func is_paralysed() -> bool:
	return false
