class_name BoardCell
extends Sprite2D

var occupying_piece: ChessPiece = null
var cell_position: Vector2i
var cell_color_normal
var board: Board

var blocked: bool = false
var can_attack = false
var can_move = false

# TODO: Tile colours
const color_white = ColorController.colors["primary"]
const color_black = ColorController.colors["secondary"]
const color_move = ColorController.colors["c1"]
const color_attack = ColorController.colors["c2"]
const color_blocked = ColorController.colors["c3"]
const color_selected = ColorController.colors["c4"]

func Init(parent_board: Board, cell_position: Vector2i):
	self.board = parent_board
	self.cell_position = cell_position
	self.cell_color_normal = color_black
	if (cell_position.x + cell_position.y) % 2 == 0:
		cell_color_normal = color_white

func set_color(color):
	self_modulate = color
