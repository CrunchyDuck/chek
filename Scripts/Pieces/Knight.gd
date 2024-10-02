extends ChessPiece

func _highlight_board_cells():
  _move_attack(pos + Vector2i(1, 2))
  _move_attack(pos + Vector2i(2, 1))

  _move_attack(pos + Vector2i(1, -2))
  _move_attack(pos + Vector2i(2, -1))
  
  _move_attack(pos + Vector2i(-1, 2))
  _move_attack(pos + Vector2i(-2, 1))

  _move_attack(pos + Vector2i(-1, -2))
  _move_attack(pos + Vector2i(-2, -1))
