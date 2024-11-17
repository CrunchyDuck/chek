class_name ChessPiece
extends Sprite2D

var node_sprite: Sprite2D = self

var piece_type: BoardBase.ePieces
var board: BoardBase
var coordinates: Vector2i
var move_count: int = 0
var owned_by: int
var _orientation: ChessPiece.Orientation = Orientation.North
var orientation: ChessPiece.Orientation:
  get:
    return _orientation
  set(value):
    _orientation = value
    node_sprite.rotation_degrees = float(orientation - 180)

var owned_by_player: Player:
  get:
    if owned_by == null or board == null:
      return null
    return GameController.players_by_game_id.get(owned_by)
    
var in_cell: BoardCell:
  get:
    if board == null:
      return null
    return board.get_cell(coordinates)

signal on_kill(killer, victim)
signal on_killed(killer, victim)

# TODO: Make pieces use different spite based on owner
func Init(_coordinates: Vector2i, _orientation: ChessPiece.Orientation, _owned_by: int, _board: BoardBase, _piece_type: BoardBase.ePieces) -> void:
  self.coordinates = _coordinates
  self.orientation = _orientation
  self.owned_by = _owned_by
  self.board = _board
  self.piece_type = _piece_type
  on_killed.connect(_on_killed)

# This lets us rotate vectors to be from the perspective of its team.
# y = 1 for the top of the board (Black, in a normal game), will be y = -1 relative to their facing.
func _rotate_to_orientation(vec: Vector2i) -> Vector2i:
  var v = Vector2(vec)
  v = v.rotated(deg_to_rad(orientation)).round()
  # As we only rotate by 90, 180 or 270 degrees, integer inputs will always have integer outputs.
  # Thus, this case loses no information.
  return Vector2i(v)

func highlight_board_cells(actions: Array[BoardPlayable.GameAction]):
  for action in actions:
    if action == null:
      continue
    var target_cell = board.get_cell(action.target)
    target_cell.contained_action = action
    
# Gets a nicely serializable description of possible moves/attacks a piece can do
func _get_actions() -> Array[BoardPlayable.GameAction]:
  assert(false, "_get_actions not overridden in " + get_class())
  return []
  
# Whether a cell passes the basic requirements for movement.
func _can_move(target_position: Vector2i) -> bool:
  var target_cell: BoardCell = board.get_cell(target_position)
  return target_cell != null and target_cell.unobstructed
  
# Whether a cell passes the basic requirements for attacking.
func _can_attack(target_position: Vector2i) -> bool:
  var target_cell: BoardCell = board.get_cell(target_position)
  return target_cell != null and target_cell.occupying_piece != null and\
    not owned_by_player.friendly.has(target_cell.occupying_piece.owned_by)

# Try to move in a line, or attack what blocks that line.
func _act_in_line(direction: Vector2i) -> Array[BoardPlayable.GameAction]:
  var actions: Array[BoardPlayable.GameAction] = []
  var dist: int = 1
  while dist < 50:  # Arbitrary cap to prevent infinite loop
    var target_cell = board.get_cell(coordinates + _rotate_to_orientation(direction * dist))
    # Off the board.
    if target_cell == null:
      break
    actions.append(_act_on_cell(target_cell.cell_coordinates))

    # Will be replaced with a modifier check in the future.
    if target_cell.occupying_piece != null:
      break
    # Can happen if we loop around.
    if target_cell.occupying_piece == self:
      break
    
    dist += 1
    if dist == 50:
      print("Reached iteration cap for piece highlighting")
  return actions

# A standard move or attack to a cell.
func _act_on_cell(cell: Vector2i) -> BoardPlayable.GameAction:
  if board.game_settings.no_retreat:
    var to_cell = _rotate_to_orientation(cell - coordinates)
    if to_cell.y < 0:
      return null
  
  if _can_attack(cell):
    return BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.AttackMove, coordinates, cell)
  elif _can_move(cell):
    return BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, cell)
  return null
    
func _on_killed(killer: ChessPiece, victim: ChessPiece):
  queue_free()
  
func serialize() -> BoardBase.PieceState:
  var ps = BoardBase.PieceState.new(
    piece_type,
    coordinates,
    orientation,
    owned_by,
  )
  return ps
    
enum Orientation {
  # South is the start as y is down in Godot.
  South = 0,
  West = 90,
  North = 180,
  East = 270,
}
