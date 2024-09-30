class_name Board
extends Node2D

var prefab_board_cell = preload("res://Prefabs/Board/BoardCell.tscn")
var size: Vector2i = Vector2i(8, 8)
const cell_size : Vector2i = Vector2i(64, 64)
var cells = []  # x/y 2D array

var _selected_cell: BoardCell = null

func Init(size: Vector2i):
	# Create cells
	for x in size.x:
		var row = []
		for y in size.y:
			var board_cell = prefab_board_cell.instantiate()
			board_cell.Init(self, Vector2i(x, y))
			self.position = self.grid_to_position(x, y)
			row.append(board_cell)
			add_child(board_cell)
			
func _ready() -> void:
	pass

func grid_to_position(x: int, y: int) -> Vector2:
	var pos: Vector2 = self.position
	pos.x += x * cell_size.x
	pos.y += y * cell_size.y
	return pos

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
			cell.color_normal()
			cell.can_move = false
			cell.can_attack = false
	_selected_cell = null

# TODO: Implement
func attack_to_cell(to_cell: BoardCell):
	pass
	
# TODO: Implement
func move_to_cell(to_cell: BoardCell):
	pass
