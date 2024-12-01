extends ChessPiece

var piece_description =\
ColorControllers.color_text("Untrustworthy. Liability.\n", ColorControllers.description_color)\
+ "Alternate between diagonal and cardinal movement"

func _init():
	piece_type = ePieces.Shifter
	
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	
	if move_count % 2 == 0:
		actions += _act_in_line(Vector2i(1, 1))
		actions += _act_in_line(Vector2i(1, -1))
		actions += _act_in_line(Vector2i(-1, 1))
		actions += _act_in_line(Vector2i(-1, -1))
	if move_count % 2 == 1:
		actions += _act_in_line(Vector2i(0, 1))
		actions += _act_in_line(Vector2i(0, -1))
		actions += _act_in_line(Vector2i(-1, 0))
		actions += _act_in_line(Vector2i(1, 0))
	return actions
