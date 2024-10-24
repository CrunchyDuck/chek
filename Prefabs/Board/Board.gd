class_name Board
extends Control

var controller: GameController = null
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
		return Vector2(grid_size * cell_size) * scale

var _selected_cell: BoardCell = null
var board_wrapping: bool = false

@onready
var node_cells: Control = $Cells

@onready
var node_pieces: Control = $Pieces

signal action_performed(action: Board.GameAction)

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

func grid_to_position(x: int, y: int) -> Vector2:
	var pos: Vector2
	pos.x += x * cell_size.x
	pos.y += y * cell_size.y
	return pos

func position_to_cell(pos: Vector2) -> BoardCell:
	# Relative to our position
	pos -= position
	if pos.x < 0 or pos.y < 0 or pos.x > bounds.x or pos.y > bounds.x:
		return null
	var x = int(pos.x) / cell_size.x
	var y = int(pos.y) / cell_size.y
	
	return grid[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
	var x = pos.x
	var y = pos.y
	if board_wrapping:
		x = wrapi(x, 0, grid_size.x - 1)
		y = wrapi(x, 0, grid_size.y - 1)
	
	if x < 0 or y < 0 or x > (grid_size.x - 1) or y > (grid_size.y - 1):
		return null
	
	return grid[y][x]

func click_on_cell(new_cell: BoardCell):
	if new_cell == null or new_cell.selected:
		deselect_cell()
	elif new_cell.contained_action != null:
		perform_action(new_cell.contained_action)
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

# TODO: Move this to GameController, likely.
func perform_action(action: Board.GameAction) -> bool:
	# Check if action is allowed with GameController/Player object.
	if not controller.is_action_legal(action):
		return false
	
	var anything_performed = false
	var current_action = action
	while current_action != null:
		match current_action.type:
			Board.eActionType.Move:
				if not _move_to_cell(current_action.source, current_action.target):
					break
			Board.eActionType.Attack:
				if not _attack_to_cell(current_action.source, current_action.target):
					break
			Board.eActionType.AttackMove:
				if not _attack_to_cell(current_action.source, current_action.target):
					break
				if not _move_to_cell(current_action.source, current_action.target):
					break
			Board.eActionType.Spawn:
				pass
			_:
				assert(false, "Unhandled eActionType type in perform_action")
		anything_performed = true
		current_action = current_action.next_action
		
	if anything_performed:
		action_performed.emit(action)
		return true
	return false

func _attack_to_cell(source: Vector2i, destination: Vector2i) -> bool:
	var killer = get_cell(source).occupying_piece
	var victim = get_cell(destination).occupying_piece
	if killer == null or victim == null:
		return false
	killer.on_kill.emit(killer, victim)
	victim.on_killed.emit(killer, victim)
	get_cell(destination).occupying_piece = null
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
	return true
	
func _position_board():
	var new_position = get_viewport_rect().size / 2
	new_position -= board_size / 2
	position = new_position

class GameAction:
	# Describes an action that has taken place on the board.
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

enum eActionType {
	Move,
	# TODO: add "Jump" movetype, which does not do line-cast checks.
	Attack,
	AttackMove,  # Not quite, but almost shorthand for "attack this tile, then move then." Changed by some modifiers.
	Spawn,
}
