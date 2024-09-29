extends ChessPiece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass


func CanAttack(attack_pos: Vector2i) -> bool:
  var relative_position : Vector2i = attack_pos - pos
  relative_position = RotateVectorRelativeToTravelDirection(relative_position)
  # Can only attack diagonals in front of it.
  
  if (abs(relative_position.x) != 1):
    return false
  if (relative_position.y != 1):
    return false
  return true
  
func CanMove(move_pos: Vector2i) -> bool:
  var relative_position : Vector2i = move_pos - pos
  relative_position = RotateVectorRelativeToTravelDirection(relative_position)
  if (relative_position == Vector2i(0, 1)):
    return true
  elif (move_count == 0 and relative_position == Vector2i(0, 2)):
    return true
  
  return false
