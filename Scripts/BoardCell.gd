class_name BoardCell
extends Node2D

# References
@onready var sprite: Sprite2D = $Sprite2D

var occupying_piece: ChessPiece = null
var cell_position: Vector2i
var cell_color_normal: Color
var board: Board

var open: bool:
  get:
    return not blocked and occupying_piece == null
var blocked: bool = false
var can_attack: bool = false
var can_move: bool = false

# TODO: Tile colours
const color_white: Color = ColorController.colors["primary"]
const color_black: Color = ColorController.colors["secondary"]
const color_move: Color = ColorController.colors["c1"]
const color_attack: Color = ColorController.colors["c2"]
const color_blocked: Color = ColorController.colors["c3"]
const color_selected: Color = ColorController.colors["c4"]

func Init(parent_board: Board, cell_position: Vector2i):
  self.board = parent_board
  self.cell_position = cell_position
  self.cell_color_normal = color_black
  if (cell_position.x + cell_position.y) % 2 == 0:
    self.cell_color_normal = color_white
  set_color(self.cell_color_normal)

func set_color(color):
  sprite.self_modulate = color
