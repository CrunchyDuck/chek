class_name ChessPiece
extends Node2D

var board: Board:
  get:
    if in_cell == null:
      return null
    return in_cell.board
var in_cell: BoardCell
var pos: Vector2i:
  get:
    return in_cell.cell_coordinates
var move_count: int = 0
var owned_by: GameController.Player
var orientation: ChessPiece.Orientation = Orientation.North

# TODO: Make pieces use different spite based on owner
func Init(cell: BoardCell, orientation: ChessPiece.Orientation, owned_by: GameController.Player) -> void:
  self.in_cell = cell
  self.orientation = orientation
  self.owned_by = owned_by

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

func on_kill() -> void:
  pass
  
func on_killed() -> void:
  pass
  
func _can_move(target_cell: BoardCell) -> bool:
  return target_cell != null and target_cell.unobstructed
  
func _can_attack(target_cell: BoardCell) -> bool:
  return target_cell != null and target_cell.occupying_piece != null and\
      not owned_by.friendly.has(target_cell.occupying_piece.owned_by)

enum Orientation {
  # South is the start as y is down in Godot.
  South = 0,
  West = 90,
  North = 180,
  East = 270,
}
