extends ChessPiece

func _highlight_board_cells():
  _move_attack_in_line(Vector2i(0, 1))
  _move_attack_in_line(Vector2i(0, -1))
  _move_attack_in_line(Vector2i(1, 0))
  _move_attack_in_line(Vector2i(-1, 0))
