extends ChessPiece

func _highlight_board_cells():
  _highlight_moves()
  _highlight_attacks()

func _highlight_moves():
  var target_cell: BoardCell
  target_cell = board.get_cell(pos + _rotate_to_orientation(Vector2i(0, 1)))
  if _can_move(target_cell):
    target_cell.can_move = true
  
  # TODO: Stop this from jumping pieces.
  if move_count == 0:
    target_cell = board.get_cell(pos + _rotate_to_orientation(Vector2i(0, 2)))
    if _can_move(target_cell):
      target_cell.can_move = true

func _highlight_attacks():
  var target_cell: BoardCell
  target_cell = board.get_cell(pos + _rotate_to_orientation(Vector2i(1, 1)))
  if _can_attack(target_cell):
    target_cell.can_attack = true
  
  target_cell = board.get_cell(pos + _rotate_to_orientation(Vector2i(-1, 1)))
  if _can_attack(target_cell):
    target_cell.can_attack = true
