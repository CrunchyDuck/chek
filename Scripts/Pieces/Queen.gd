extends ChessPiece

# Abstract base functions
func _highlight_board_cells():
  for x in range(-1, 2):
    for y in range(-1, 2):
      if x == 0 and y == 0:
        continue
      _move_attack_in_line(Vector2i(x, y))
