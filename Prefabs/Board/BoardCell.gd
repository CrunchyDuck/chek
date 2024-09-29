class_name BoardCell
extends Node2D

var occupying_piece: ChessPiece = null
var cell_position: Vector2i
var board: Board

var highlight_move;
var highlight_attack;

func Init(parent_board: Board, cell_position: Vector2i):
  self.board = parent_board
  self.cell_position = cell_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
