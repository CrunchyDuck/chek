class_name VictoryPieceCapture
extends VictoryCondition

var sacred_piece_type: ChessPiece.ePieces
var lose_all_not_any: bool
var last_state: BoardBase.BoardState
var player_sacred_count: Dictionary = {}

static func can_start_game(state: BoardBase.BoardState, sacred_piece_type: ChessPiece.ePieces, report_error: bool) -> bool:
	for p in state.players:
		var count = p.pieces_by_type().get(sacred_piece_type, []).size()
		if count == 0:
			if report_error:
				MessageController.system_message("Commander " + str(p.id) + " has none of the sacred piece.")
			return false
	return true

func _init(starting_state: BoardBase.BoardState, sacred_piece_type: ChessPiece.ePieces, lose_all_not_any: bool):
	if not can_start_game(starting_state, sacred_piece_type, false):
		return
	self.sacred_piece_type = sacred_piece_type
	self.lose_all_not_any = lose_all_not_any
	
	last_state = starting_state
	for p in last_state.players:
		var count = p.pieces_by_type().get(sacred_piece_type, []).size()
		if count == 0:
			MessageController.add_message("Player " + str(p.id) + " has none of the sacred piece.")
		player_sacred_count[p.id] = count

func evaluate_victory(state: BoardBase.BoardState, rules: BoardBase.GameSettings) -> Array[int]:
	return _elimination_victory(state)

func evaluate_defeat(state: BoardBase.BoardState, rules: BoardBase.GameSettings) -> Array[int]:
	for p in state.players:
		if defeated.has(p.id):
			continue
		# Check if the player has lost a relevant piece.
		var pieces: Dictionary = p.pieces_by_type()
		var num_remaining = pieces.get(sacred_piece_type, []).size()
		
		if lose_all_not_any:
			if num_remaining == 0:
				defeated.append(p.id)
				continue
		elif num_remaining < player_sacred_count[p.id]:
			defeated.append(p.id)
			continue
		# In case the player gains a piece
		player_sacred_count[p.id] = num_remaining
		
	last_state = state
	return defeated
