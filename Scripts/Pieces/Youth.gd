extends ChessPiece

var piece_description =\
ColorControllers.color_text("Weaponized youth.\n", ColorControllers.description_color)\
+ "When killed, converts victor."\
+ "Move and take diagonals."

func _init():
	piece_type = ePieces.Youth
	
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	actions += _act_in_line(Vector2i(1, 1), 1)
	actions += _act_in_line(Vector2i(1, -1), 1)
	#actions += _act_in_line(Vector2i(-1, 1), 1)
	#actions += _act_in_line(Vector2i(-1, -1), 1)
	return actions

func _on_killed(killer: ChessPiece, victim: ChessPiece):
	killer.owned_by = victim.owned_by
	super(killer, victim)
