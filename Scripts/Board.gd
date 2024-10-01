class_name Board
extends Node2D

var prefab_board_cell = preload("res://Prefabs/Board/BoardCell.tscn")
var prefab_pawn = preload("res://Prefabs/Pieces/Pawn.tscn")
var size: Vector2i = Vector2i(8, 8)
const cell_size : Vector2i = Vector2i(64, 64)
var bounds: Vector2:
	get:
		return size * cell_size
var cells = []  # x/y 2D array

var _selected_cell: BoardCell = null

var board_wrapping: bool = false

func Init(size: Vector2i):
	# Create cells
	for y in size.y:
		var row = []
		for x in size.x:
			var board_cell = prefab_board_cell.instantiate()
			add_child(board_cell)  # _ready() is not called till this is done!
			board_cell.Init(self, Vector2i(x, y))
			board_cell.position = self.grid_to_position(x, y)
			row.append(board_cell)
		cells.append(row)
	
	var pawn = prefab_pawn.instantiate()
	var parent_cell = cells[3][2]
	parent_cell.add_child(pawn)
	pawn.Init(self, parent_cell, ChessPiece.Orientation.North)
			
func _ready() -> void:
	Init(Vector2i(8, 8))

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
	
	return cells[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
	var x = pos.x
	var y = pos.y
	if board_wrapping:
		x = wrapi(x, 0, size.x - 1)
		y = wrapi(x, 0, size.y - 1)
	
	if x < 0 or y < 0 or x > size.x - 1 or y > size.y - 1:
		return null
	
	return cells[y][x]

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
			deselect_cell()
		else:
			_on_click(event)
			
func _on_click(event: InputEventMouseButton):
	var new_cell = position_to_cell(get_global_mouse_position())
	if new_cell != null:
		click_on_cell(new_cell)
	else:
		deselect_cell()

func click_on_cell(new_cell: BoardCell):
	if new_cell == null:
		select_cell(new_cell)
		
	if new_cell.can_attack:
		attack_to_cell(new_cell)
		return
	
	if new_cell.can_move:
		move_to_cell(new_cell)
		return

	select_cell(new_cell)

func select_cell(to_cell: BoardCell):
	deselect_cell()
	_selected_cell = to_cell
	if _selected_cell == null:
		return
	_selected_cell.set_color(BoardCell.color_selected)
	
	# Check attack/moves on cells
	if _selected_cell.occupying_piece == null:
		return
	for column in cells:
		for cell in column:
			if cell == _selected_cell:
				continue
			if _selected_cell.occupying_piece._can_attack(cell):
				cell.can_attack = true
				cell.set_color(BoardCell.color_attack)
			elif _selected_cell.occupying_piece._can_move(cell):
				cell.can_move = true
				cell.set_color(BoardCell.color_move)
		
func deselect_cell():
	if _selected_cell == null:
		return
		
	for column in cells:
		for cell in column:
			cell.set_color(cell.cell_color_normal)
			cell.can_move = false
			cell.can_attack = false
	_selected_cell = null

# TODO: Implement
func attack_to_cell(to_cell: BoardCell):
	pass
	
# TODO: Implement
func move_to_cell(to_cell: BoardCell):
	pass
