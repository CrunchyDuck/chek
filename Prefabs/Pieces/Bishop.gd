extends ChessPiece

var piece_description =\
ColorControllers.color_text("Divine salesman.\n", ColorControllers.description_color)\
+ "Move and take diagonals."

func _ready():
	piece_type = ePieces.Bishop
	
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	actions += _act_in_line(Vector2i(1, 1))
	actions += _act_in_line(Vector2i(1, -1))
	actions += _act_in_line(Vector2i(-1, 1))
	actions += _act_in_line(Vector2i(-1, -1))
	return actions
