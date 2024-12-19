class_name VictoryAnnihilation
extends VictoryCondition


func evaluate_victory(state: BoardBase.BoardState, rules: GameSettings) -> Array[int]:
	return _elimination_victory(state)

func evaluate_defeat(state: BoardBase.BoardState, rules: GameSettings):
	for p in state.players:
		var player = GameController.players_by_game_id[p.id]
		if player.defeated:
			continue
		
		var valid_pieces = []
		for piece in p.pieces:
			if piece.type != ChessPiece.ePieces.Blocker:
				valid_pieces.append(piece)
		
		if valid_pieces.size() == 0:
			# TODO: Blockers check
			MessageController.system_message(player.character_name + " has been defeated!")
			player.defeated = true
