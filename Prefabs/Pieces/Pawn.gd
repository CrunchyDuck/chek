extends ChessPiece

var piece_description =\
ColorControllers.color_text("Fearless front line. Nothing to lose.\n", ColorControllers.description_color)\
+ "Only moves forward.
Attacks diagonal.
Promotion at end of board."

func _ready():
  piece_type = ePieces.Pawn
  
func _get_actions() -> Array[BoardPlayable.GameAction]:
  var actions: Array[BoardPlayable.GameAction] = []
  var target_position: Vector2i
  # Moves
  target_position = coordinates + _rotate_to_orientation(Vector2i(0, 1))
  if _can_move(target_position):
    actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, target_position))
  
  # TODO: Stop this from jumping pieces.
  if move_count == 0:
    target_position = coordinates + _rotate_to_orientation(Vector2i(0, 2))
    if _can_move(target_position):
      actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, target_position))
  
  # Attacks
  target_position = coordinates + _rotate_to_orientation(Vector2i(1, 1))
  if _can_attack(target_position):
    actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.AttackMove, coordinates, target_position))

  target_position = coordinates + _rotate_to_orientation(Vector2i(-1, 1))
  if _can_attack(target_position):
    actions.append(BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.AttackMove, coordinates, target_position))
  
  return actions
