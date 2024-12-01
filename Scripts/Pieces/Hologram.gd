extends ChessPiece

# Cannot attack. Move any direction. Swap places with friendly pieces
var piece_description =\
ColorControllers.color_text("Cutting edge illusion.\n", ColorControllers.description_color)\
+ "Cannot attack. Move any direction.\n"\
+ "Swap place with adjacent or friendly pieces."

func _init():
	piece_type = ePieces.Hologram
	
func _get_actions() -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	var my_cell = coordinates
	for p in owned_by_player.pieces:
		var p_cell = p.coordinates
		actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.SwapPosition, my_cell, p_cell))
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			var target_cell: BoardCell = board.get_cell(coordinates + Vector2i(x, y))
			if target_cell == null:
				continue
			if target_cell.unobstructed:
				actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, my_cell, target_cell.cell_coordinates))
			# Ensures we don't put multiple actions, swapping with adjacent friendly pieces.
			elif target_cell.occupying_piece.owned_by != owned_by:
				actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.SwapPosition, my_cell, target_cell.cell_coordinates))
	return actions

func is_paralysed() -> bool:
	return false
