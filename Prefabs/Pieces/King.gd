extends ChessPiece

var piece_description =\
ColorControllers.color_text("Ineffective figurehead.\n", ColorControllers.description_color)\
+ "Move and take any direction."

func _ready():
  piece_type = ePieces.King
  
func _get_actions() -> Array[BoardPlayable.GameAction]:
  var actions: Array[BoardPlayable.GameAction] = []
  for x in range(-1, 2):
    for y in range(-1, 2):
      if x == 0 and y == 0:
        continue
      var act = _act_on_cell(coordinates + Vector2i(x, y))
      if act != null:
        actions.append(act)
  return actions
