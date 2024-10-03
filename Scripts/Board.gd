class_name Board
extends Node2D

var size: Vector2i = Vector2i(8, 8)
const cell_size : Vector2i = Vector2i(64, 64)
var bounds: Vector2:
	get:
		return size * cell_size
var grid = []  # x/y 2D array

var _selected_cell: BoardCell = null

var board_wrapping: bool = false

func Init(grid):
	self.grid = grid
	size = Vector2i(grid.size(), grid[0].size())
	# Add cells as children
	for y in size.y:
		for x in size.x:
			var board_cell = grid[y][x]
			add_child(board_cell)  # _ready() is not called till this is done!
			board_cell.Init(self, Vector2i(x, y))
			board_cell.position = self.grid_to_position(x, y)

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
		x = wrapi(x, 0, size.x - 1)
		y = wrapi(x, 0, size.y - 1)
	
	if x < 0 or y < 0 or x > size.x - 1 or y > size.y - 1:
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

func perform_action(action: GameController.GameAction):
	# Check if action is allowed with GameController/Player object.
	match action.type:
		GameController.eActionType.Move:
			pass
		GameController.eActionType.Attack:
			pass
		_:
			assert(false, "Unhandled eActionType type in perform_action")

func _attack_to_cell(to_cell: BoardCell):
	var killer = _selected_cell.occupying_piece
	var victim = to_cell.occupying_piece
	killer.on_kill.emit(killer, victim)
	victim.on_killed.emit(killer, victim)
	to_cell.occupying_piece = null
	move_to_cell(to_cell)
	
func _move_to_cell(to_cell: BoardCell):
	var piece = _selected_cell.occupying_piece
	piece.move_count += 1
	_selected_cell.occupying_piece = null
	to_cell.occupying_piece = piece
	deselect_cell()
