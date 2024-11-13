class_name Board
extends Control

var grid_size: Vector2i:
	get:
		var y = grid.size()
		if y == 0:
			return Vector2i(0, 0)
		var x = grid[0].size()
		return Vector2i(x, y)
const cell_size : Vector2i = Vector2i(64, 64)
var bounds: Vector2:
	get:
		return grid_size * cell_size
var grid: Array[Array] = []  # x/y 2D array
var board_size: Vector2:
	get:
		return Vector2(grid_size * cell_size)

var _selected_cell: BoardCell = null
var board_wrapping: bool = false

var game_settings: GameSetupRules.GameSettings:
	get:
		return GameController.game_settings

@onready
var node_cells: Control = $Cells

@onready
var node_pieces: Control = $Pieces

func _ready():
	# This is to make the sprites not go below 0,0 in this object
	node_cells.position += Vector2(cell_size) / 2
	node_pieces.position += Vector2(cell_size) / 2

func create_new_grid(_grid_size: Vector2i) -> Array[Array]:
	for n in node_cells.get_children():
		n.queue_free()

	grid = []
	for y in _grid_size.y:
		var row = []
		for x in _grid_size.x:
			var board_cell: BoardCell = PrefabController.get_prefab("Board.BoardCell").instantiate()
			board_cell.cell_coordinates = Vector2i(x, y)
			board_cell.board = self
			node_cells.add_child(board_cell)
			board_cell.position = cell_to_position(Vector2i(x, y))
			row.append(board_cell)
		grid.append(row)
	return grid

func clear_pieces():
	for n in node_pieces.get_children():
		n.queue_free()
		
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

#region Cell selection
func grid_to_position(x: int, y: int) -> Vector2:
	var pos: Vector2
	pos.x += x * cell_size.x
	pos.y += y * cell_size.y
	return pos

func cell_to_position(cell: Vector2i) -> Vector2:
	return cell * cell_size

func position_to_cell(pos: Vector2) -> BoardCell:
	# Relative to our position
	# TODO: When I implement the 3D console, this will need to be changed.
	pos -= global_position
	if pos.x < 0 or pos.y < 0 or pos.x > bounds.x or pos.y > bounds.x:
		return null
	var x = int(pos.x) / cell_size.x
	var y = int(pos.y) / cell_size.y
	
	return grid[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
	if board_wrapping:
		pos.x = wrapi(pos.x, 0, grid_size.x - 1)
		pos.y = wrapi(pos.y, 0, grid_size.y - 1)
	
	if not is_coordinate_in_bounds(pos):
		return null
	
	return grid[pos.y][pos.x]

func is_coordinate_in_bounds(coordinate: Vector2i) -> bool:
	var x = coordinate.x
	var y = coordinate.y
	return x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y
#endregion

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
	
func _position_board():
	var new_position = get_viewport_rect().size / 2
	new_position -= board_size / 2
	position = new_position

class GameAction:
	# Describes an action that to take place on the board.
	var player: int
	var type: Board.eActionType
	var source: Vector2i
	var target: Vector2i
	var next_action: GameAction
	
	func _init(player: int, type: Board.eActionType, source: Vector2i, target: Vector2i, next_action: GameAction = null) -> void:
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
