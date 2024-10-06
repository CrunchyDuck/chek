class_name BoardCell
extends Node2D

# References
@onready var sprite: Sprite2D = $Sprite2D

var board: Board = null
var _occupying_piece: ChessPiece = null
# I don't like how much is implicitly done here.
# If this proves to cause issues, I should go through signals instead, like on_kill
var occupying_piece: ChessPiece:
	get:
		return _occupying_piece
	set(piece):
		if _occupying_piece != null:
			remove_child(_occupying_piece)
			_occupying_piece.in_cell = null
			
		_occupying_piece = piece
		if _occupying_piece != null:
			add_child(piece)
			_occupying_piece.in_cell = self
var cell_coordinates: Vector2i
var color_normal: Color

var unobstructed: bool:
	get:
		return not blocked and occupying_piece == null

var selected: bool:
	get:
		return _selected
	set(value):
		_selected = value
		_update_color()
var blocked: bool:
	get:
		return _blocked
	set(value):
		_blocked = value
		_update_color()
var contained_action: Board.GameAction:
	get:
		return _contained_action
	set(value):
		_contained_action = value
		_update_color()

var _selected = false
var _blocked: bool = false
var _contained_action: Board.GameAction = null

# TODO: Tile colours
const color_white: Color = ColorController.colors["primary"]
const color_black: Color = ColorController.colors["secondary"]
const color_move: Color = ColorController.colors["c2"]
const color_attack: Color = ColorController.colors["c5"]
const color_blocked: Color = ColorController.colors["c6"]
const color_selected: Color = ColorController.colors["c3"]

func Init(board: Board, cell_coordinates: Vector2i):
	self.board = board
	self.cell_coordinates = cell_coordinates
	self.color_normal = color_black
	if (cell_coordinates.x + cell_coordinates.y) % 2 == 0:
		self.color_normal = color_white
	_update_color()

func reset_state():
	blocked = false
	selected = false
	contained_action = null
	_update_color()

func _update_color():
	var color: Color
	if selected:
		color = color_selected
	elif blocked:
		color = color_blocked	
	elif contained_action != null:
		match contained_action.type:
			Board.eActionType.Move:
				color = color_move
			Board.eActionType.Attack, Board.eActionType.AttackMove:
				color = color_attack
			_:
				assert(false, "Unhandled eActionType in BoardCell " + str(cell_coordinates))
	else:
		color = color_normal

	sprite.self_modulate = color
