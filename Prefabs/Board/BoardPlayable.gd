class_name BoardPlayable
extends BoardBase

var _selected_cell: BoardCell = null

func _input(event: InputEvent) -> void:
	super(event)
	if not interaction_allowed:
		return
		
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
			deselect_cell()
		else:
			_on_click(event)
			
func _on_click(_event: InputEventMouseButton):
	var new_cell = position_to_cell(get_global_mouse_position())
	if new_cell != null:
		click_on_cell(new_cell)
	else:
		deselect_cell()

func click_on_cell(new_cell: BoardCell):
	if new_cell == null or new_cell.selected:
		deselect_cell()
	elif new_cell.contained_action != null:
		GameController.try_perform_action.rpc_id(1, new_cell.contained_action.serialize())
		deselect_cell()
	else:
		select_cell(new_cell)

func select_cell(to_cell: BoardCell):
	deselect_cell()
	_selected_cell = to_cell
	if _selected_cell == null:
		return
	_selected_cell.selected = true
	
	# Check attack/moves on grid
	if _selected_cell.occupying_piece == null:
		return
	
	if not game_settings.no_gods and _selected_cell.occupying_piece.owned_by != GameController.player.game_id:
		return
	var actions = _selected_cell.occupying_piece._get_actions()
	_selected_cell.occupying_piece.highlight_board_cells(actions)

func deselect_cell():
	for column in grid:
		for cell in column:
			cell.reset_state()
	_selected_cell = null

func _attack_to_cell(source: Vector2i, destination: Vector2i) -> bool:
	var cs = get_cell(source)
	var cd = get_cell(destination)
	if cs == null or cd == null:
		return false
	
	var killer = cs.occupying_piece
	var victim = cd.occupying_piece
	killer.owned_by_player.player_stats.pieces_killed += 1
	victim.owned_by_player.player_stats.pieces_lost += 1
	if killer == null or victim == null:
		return false
	killer.on_kill.emit(killer, victim)
	victim.on_killed.emit(killer, victim)
	return true
	
func _move_to_cell(source: Vector2i, destination: Vector2i) -> bool:
	var source_cell = get_cell(source)
	var destination_cell = get_cell(destination)
	if source_cell.occupying_piece == null:
		return false
	if destination_cell.occupying_piece != null:
		return false
	var piece =	source_cell.occupying_piece
	piece.move_count += 1
	source_cell.occupying_piece = null
	destination_cell.occupying_piece = piece
	piece.coordinates = destination_cell.cell_coordinates
	piece.position = cell_to_position(piece.coordinates)
	
	piece.owned_by_player.player_stats.distance_moved = (Vector2(source) - Vector2(destination)).length()
	# Rotate piece if at the end of the board.
	var cell_ahead = piece.coordinates + piece._rotate_to_orientation(Vector2i(0, 1))
	if not is_coordinate_in_bounds(cell_ahead):
		piece.on_reached_end_of_board.emit()
		piece.orientation = wrapi(piece.orientation + 180, 0, 360)
	return true
	
func _swap_cells(source: Vector2i, destination: Vector2i) -> bool:
	var c1 = get_cell(source)
	var c2 = get_cell(destination)
	if c1 == null or c2 == null:
		return false
	
	var p1 = c1.occupying_piece
	var p2 = c2.occupying_piece
	if p1 == null or p2 == null:
		return false
	
	var dist = (Vector2(c1.cell_coordinates) - Vector2(c2.cell_coordinates)).length()
	p1.owned_by_player.player_stats.distance_moved += dist
	p2.owned_by_player.player_stats.distance_moved += dist
	
	c1.occupying_piece = null
	c1.occupying_piece = p2
	p2.coordinates = c1.cell_coordinates
	p2.position = cell_to_position(p2.coordinates)
	
	c2.occupying_piece = null
	c2.occupying_piece = p1
	p1.coordinates = c2.cell_coordinates
	p1.position = cell_to_position(p1.coordinates)
	p1.move_count += 1
	
	var cell_ahead = p1.coordinates + p1._rotate_to_orientation(Vector2i(0, 1))
	if not is_coordinate_in_bounds(cell_ahead):
		p1.orientation = wrapi(p1.orientation + 180, 0, 360)
		
	cell_ahead = p2.coordinates + p2._rotate_to_orientation(Vector2i(0, 1))
	if not is_coordinate_in_bounds(cell_ahead):
		p2.orientation = wrapi(p2.orientation + 180, 0, 360)
	return true

func apply_fog_of_war(from_player: int):
	var pieces_dict: Dictionary = pieces_by_game_id
	var pieces: Array = []
	# Hide pieces
	for game_id in pieces_dict:
		if game_id == from_player:
			continue
		pieces = pieces_dict[game_id]
		for p in pieces:
			p.visible = false
	
	pieces = pieces_dict[from_player]
	for p in pieces:
		# Reveal those adjacent to our pieces
		for x in range(-1, 2):
			for y in range(-1, 2):
				var c = get_cell(p.coordinates + Vector2i(x, y))
				if c == null or c.occupying_piece == null:
					continue
				c.occupying_piece.visible = true
		# Reveal those we can attack.
		var acts: Array[BoardPlayable.GameAction] = p._get_actions()
		for act in acts:
			if act == null:
				continue
			if act.type == BoardPlayable.eActionType.Attack or act.type == BoardPlayable.eActionType.AttackMove:
				get_cell(act.target).occupying_piece.visible = true
	

class GameAction:
	# Describes an action that to take place on the board.
	var player: int
	var type: BoardPlayable.eActionType
	var source: Vector2i
	var target: Vector2i
	var next_action: GameAction
	
	func _init(player: int, type: BoardPlayable.eActionType, source: Vector2i, target: Vector2i, next_action: GameAction = null) -> void:
		self.player = player
		self.type = type
		self.source = source
		self.target = target
		self.next_action = next_action
	
	func serialize() -> Dictionary:
		var d = {}
		d.player = player
		d.type = type
		d.source = source
		d.target = target
		d.next_action = {}
		if next_action != null:
			d.next_action = next_action.serialize()
		return d
	
	static func deserialize(data: Dictionary) -> GameAction:
		var next_act = null
		if not data.next_action.is_empty():
			next_act = GameAction.deserialize(data.next_action)	
			
		var ga = GameAction.new(
			data.player,
			data.type,
			data.source,
			data.target,
			next_act,
		)
		return ga

enum eActionType {
	Move,
	# TODO: add "Jump" movetype, which does not do line-cast checks.
	Attack,
	AttackMove,  # Not quite, but almost shorthand for "attack this tile, then move then." Changed by some modifiers.
	Spawn,
	SwapPosition,
}
