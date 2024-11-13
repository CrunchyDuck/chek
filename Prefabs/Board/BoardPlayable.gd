class_name BoardPlayable
extends BoardBase

var _selected_cell: BoardCell = null

func _input(event: InputEvent) -> void:
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
	
	var actions = _selected_cell.occupying_piece._get_actions()
	_selected_cell.occupying_piece.highlight_board_cells(actions)

func deselect_cell():
	for column in grid:
		for cell in column:
			cell.reset_state()
	_selected_cell = null

func _attack_to_cell(source: Vector2i, destination: Vector2i) -> bool:
	var killer = get_cell(source).occupying_piece
	var victim = get_cell(destination).occupying_piece
	if killer == null or victim == null:
		return false
	killer.on_kill.emit(killer, victim)
	victim.on_killed.emit(killer, victim)
	get_cell(destination).occupying_piece = null
	if game_settings.divine_wind:
		killer.on_killed.emit(killer, killer)
		get_cell(source).occupying_piece = null
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
	
	# Rotate piece if at the end of the board.
	var cell_ahead = piece.coordinates + piece._rotate_to_orientation(Vector2i(0, 1))
	if not is_coordinate_in_bounds(cell_ahead):
		piece.orientation = wrapi(piece.orientation + 180, 0, 360)
	return true
	

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
}
