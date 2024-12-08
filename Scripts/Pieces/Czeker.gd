extends ChessPiece

var piece_description = ColorControllers.color_text("Acrobatic foreigner.\n", ColorControllers.description_color)\
+ "Move forward diagonals.\n"\
+ "Leap over and kill those in the way.\n"\
+ "Promotion at end of board."

var kinged: bool = false

func _init():
	piece_type = ePieces.Czeker
	on_reached_end_of_board.connect(_on_reached_end_of_board)

# TODO: Different sprite for kinged czeker
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	
	actions.append_array(act_on_diagonal(Vector2i(1, 1)))
	actions.append_array(act_on_diagonal(Vector2i(-1, 1)))
	if kinged:
		actions.append_array(act_on_diagonal(Vector2i(1, -1)))
		actions.append_array(act_on_diagonal(Vector2i(-1, -1)))

	return actions

func act_on_diagonal(diagonal: Vector2i) -> Array[BoardPlayable.GameAction]:
	var acts: Array[BoardPlayable.GameAction] = []
	var target_position = coordinates + _rotate_to_orientation(diagonal)
	if _can_move(target_position):
		acts.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, target_position))
	else:
		var leap_position = target_position + _rotate_to_orientation(diagonal)
		if _can_attack(target_position) and _can_move(leap_position):
			var mov = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, leap_position)
			var att = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Attack, leap_position, target_position)
			mov.next_action = att
			acts.append(mov)
	return acts

func _on_reached_end_of_board():
	kinged = true
