extends ChessPiece

var piece_description =\
ColorControllers.color_text("Loyal.\nPsychologically degraded.\n", ColorControllers.description_color)\
+ "Move and attack any direction.\n"\
+ "Explodes, decimating its tile, killing surrounding units.\n"

var exploded: bool = false

func _init():
	piece_type = ePieces.Bomber
	
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

func _on_killed(killer: ChessPiece, victim: ChessPiece):
	explode()
	
func _on_kill(killer: ChessPiece, victim: ChessPiece):
	explode()

func explode():
	if exploded:
		return
	exploded = true
	for x in range(-1, 2):
		for y in range(-1, 2):
			board._attack_to_cell(coordinates, coordinates + Vector2i(x, y))
	
	Helpers.destroy_node(self)		
