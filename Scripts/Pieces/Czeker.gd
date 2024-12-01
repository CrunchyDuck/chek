extends ChessPiece

var piece_description = ColorControllers.color_text("Acrobatic foreigner.\n", ColorControllers.description_color)\
+ "Move forward diagonals.\n"\
+ "Leap over and kill those in the way.\n"\
+ "Promotion at end of board."

func _init():
	piece_type = ePieces.Rook

# TODO: Kinging
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	
	var target_position = coordinates + _rotate_to_orientation(Vector2i(1, 1))
	if _can_move(target_position):
		actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, target_position))
	else:
		var leap_position = target_position + _rotate_to_orientation(Vector2i(1, 1))
		if _can_attack(target_position) and _can_move(leap_position):
			var mov = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, leap_position)
			var att = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Attack, coordinates, target_position)
			mov.next_action = att
			actions.append(mov)
			
			
	target_position = coordinates + _rotate_to_orientation(Vector2i(-1, 1))
	if _can_move(target_position):
		actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, target_position))
	else:
		var leap_position = target_position + _rotate_to_orientation(Vector2i(-1, 1))
		if _can_attack(target_position) and _can_move(leap_position):
			var mov = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, leap_position)
			var att = BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Attack, coordinates, target_position)
			mov.next_action = att
			actions.append(mov)
	
	return actions
