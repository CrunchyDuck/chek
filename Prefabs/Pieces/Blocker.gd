extends ChessPiece


var piece_description =\
ColorControllers.color_text("Decimated land.\n", ColorControllers.description_color)\
+ "Cell cannot be moved into."

func _ready():
  piece_type = ePieces.Blocker

func _get_actions() -> Array[BoardPlayable.GameAction]:
  return []
