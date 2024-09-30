class_name BoardCell
extends Node2D

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var shape: CollisionShape2D = $Area2D/CollisionShape2D

var occupying_piece: ChessPiece = null
var cell_position: Vector2i
var cell_color_normal: Color
var board: Board

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
		cell_color_normal = color_white
	self.collision_shape.shape.size = Board.cell_size
	self.collision_shape.position = Board.cell_size / 2
	self.area.input_event.connect(_on_click)

func _on_click(event: InputEventMouseButton):
	pass

func set_color(color):
	sprite.self_modulate = color
