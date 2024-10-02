extends ChessPiece

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass

func _highlight_board_cells():
  _highlight_moves()
  _highlight_attacks()

func _highlight_moves():
  var target_cell: BoardCell
  target_cell = board.get_cell(pos + _rotate_to_orientation(Vector2i(0, 1)))
  if _can_move(target_cell):
    target_cell.can_move = true
  
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
