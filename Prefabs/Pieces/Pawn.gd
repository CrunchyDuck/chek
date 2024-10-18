extends ChessPiece

func _get_actions() -> Array[Board.GameAction]:
	var actions: Array[Board.GameAction] = []
	var target_position: Vector2i
	# Moves
	target_position = coordinates + _rotate_to_orientation(Vector2i(0, 1))
	if _can_move(target_position):
		actions.append(Board.GameAction.new(owned_by, Board.eActionType.Move, coordinates, target_position))
	
	# TODO: Stop this from jumping pieces.
	if move_count == 0:
		target_position = coordinates + _rotate_to_orientation(Vector2i(0, 2))
		if _can_move(target_position):
			actions.append(Board.GameAction.new(owned_by, Board.eActionType.Move, coordinates, target_position))
	
	# Attacks
	target_position = coordinates + _rotate_to_orientation(Vector2i(1, 1))
	if _can_attack(target_position):
		actions.append(Board.GameAction.new(owned_by, Board.eActionType.AttackMove, coordinates, target_position))

	target_position = coordinates + _rotate_to_orientation(Vector2i(-1, 1))
	if _can_attack(target_position):
		actions.append(Board.GameAction.new(owned_by, Board.eActionType.AttackMove, coordinates, target_position))
	
	return actions
