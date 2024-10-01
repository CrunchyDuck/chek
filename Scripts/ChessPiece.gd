class_name ChessPiece
extends Node2D

var board: Board
var in_cell: BoardCell
var pos: Vector2i:
  get:
    return in_cell.cell_position
var move_count: int = 0
#var player_owner
var orientation: ChessPiece.Orientation = Orientation.North

func Init(board: Board, cell: BoardCell, orientation: ChessPiece.Orientation) -> void:
  self.board = board
  self.in_cell = cell
  self.orientation = orientation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

# This lets us rotate vectors to be from the perspective of its team.
# y = 1 for the top of the board (Black, in a normal game), will be y = -1 relative to their facing.
func _rotate_to_orientation(vec: Vector2i) -> Vector2i:
  var v = Vector2(vec)
  v = v.rotated(deg_to_rad(orientation)).round()
  # As we only rotate by 90, 180 or 270 degrees, integer inputs will always have integer outputs.
  # Thus, this case loses no information.
  return Vector2i(v)

# Abstract base functions
func _highlight_board_cells():
  pass
  
func _highlight_attacks():
  pass

func _highlight_moves():
  pass
  
func _move(to: BoardCell) -> void:
  pass

func _on_kill() -> void:
  pass
  
func _on_killed() -> void:
  pass

enum Orientation {
  North = 0,
  East = 90,
  South = 180,
  West = 270,
}
