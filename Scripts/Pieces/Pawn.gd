extends ChessPiece

func _get_actions() -> Array[GameController.GameAction]:
	var actions: Array[GameController.GameAction] = []
	var target_position: Vector2i
	# Moves
	target_position = pos + _rotate_to_orientation(Vector2i(0, 1))
	if _can_move(target_position):
		actions.append(GameController.GameAction.new(GameController.eActionType.Move, pos, target_position))
	
	# TODO: Stop this from jumping pieces.
	if move_count == 0:
		target_position = pos + _rotate_to_orientation(Vector2i(0, 2))
		if _can_move(target_position):
			actions.append(GameController.GameAction.new(GameController.eActionType.Move, pos, target_position))
	
	# Attacks
	target_position = pos + _rotate_to_orientation(Vector2i(1, 1))
	if _can_attack(target_position):
		actions.append(GameController.GameAction.new(GameController.eActionType.Attack, pos, target_position))

	target_position = pos + _rotate_to_orientation(Vector2i(-1, 1))
	if _can_attack(target_position):
		actions.append(GameController.GameAction.new(GameController.eActionType.Attack, pos, target_position))
	
	return actions
