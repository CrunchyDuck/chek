class_name BoardCell
extends Node2D

# References
@onready var sprite: Sprite2D = $Sprite2D

var occupying_piece: ChessPiece = null
var cell_coordinates: Vector2i
var color_normal: Color
var board: Board

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
var can_move: bool:
  get:
    return _can_move
  set(value):
    _can_move = value
    _update_color()
var can_attack: bool:
  get:
    return _can_attack
  set(value):
    _can_attack = value
    _update_color()

var _selected = false
var _blocked: bool = false
var _can_move: bool = false
var _can_attack: bool = false

# TODO: Tile colours
const color_white: Color = ColorController.colors["primary"]
const color_black: Color = ColorController.colors["secondary"]
const color_move: Color = ColorController.colors["c1"]
const color_attack: Color = ColorController.colors["c2"]
const color_blocked: Color = ColorController.colors["c3"]
const color_selected: Color = ColorController.colors["c4"]

func Init(parent_board: Board, cell_coordinates: Vector2i):
  self.board = parent_board
  self.cell_coordinates = cell_coordinates
  self.color_normal = color_black
  if (cell_coordinates.x + cell_coordinates.y) % 2 == 0:
    self.color_normal = color_white
  _update_color()

func reset_state():
  blocked = false
  can_attack = false
  can_move = false
  selected = false
  _update_color()

func _update_color():
  var color: Color
  if selected:
    color = color_selected
  elif blocked:
    color = color_blocked	
  elif can_attack:
    color = color_attack
  elif can_move:
    color = color_move
  else:
    color = color_normal

  sprite.self_modulate = color
