class_name BoardEditable
extends BoardBase

var paint_piece: BoardBase.PieceState

func _input(event: InputEvent):
	super(event)
	var _cell = position_to_cell(get_global_mouse_position())
	if Input.is_action_pressed("LMB"):
		if _cell:
			spawn_piece(paint_piece.type, _cell.cell_coordinates, paint_piece.orientation, paint_piece.player)
			GameController.board_state = serialize()
	if Input.is_action_pressed("RMB"):
		clear_cell(_cell)

func set_board_size(new_size: Vector2i):
	var _old_state = GameController.board_state
	clear_pieces()
	create_new_grid(new_size)
	
	for p in _old_state.players:
		for piece in p.pieces:
			var pos = piece.position
			if pos.x < grid_size.x and pos.y < grid_size.y:
				spawn_piece(piece.type, piece.position, piece.orientation, piece.player)
	GameController.board_state = serialize()
	_position_board()

func clear_cell(_cell: BoardCell):
	if _cell == null:
		return
	if _cell.occupying_piece == null:
		return
	Helpers.destroy_node(_cell.occupying_piece)
	GameController.board_state = serialize()
