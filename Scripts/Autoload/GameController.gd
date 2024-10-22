extends Node
# TODO: Maintain BoardState and PieceState throughout the game.

var piece_prefabs = {
	ePieces.Pawn: "Pieces.Pawn",
	ePieces.Queen: "Pieces.Queen",
	ePieces.King: "Pieces.King",
	ePieces.Rook: "Pieces.Rook",
	ePieces.Knight: "Pieces.Knight",
	ePieces.Bishop: "Pieces.Bishop",
}

var name_list = [
	"N. Laska",
	"O. Stanislav",
	"F. Danilski",
]

var board: Board
var players_by_net_id: Dictionary:
	get:
		var d = {}
		for p in Player.players.keys():
			d[p.network_id] = p
		print(d)
		return d
var players_by_game_id: Dictionary:
	get:
		var d = {}
		for p in Player.players.keys():
			d[p.game_id] = p
		print(d)
		return d

var screen_central: Control

var port: int
var ip: String

var character_name: String

var game_settings: GameSetup.GameSettings
var board_state: GameSetup.BoardState
var players_loaded: int = 0

func _ready():
	_get_references()
	PrefabController.register_networked_node("", get_path())
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	character_name = name_list.pick_random()
	
func _get_references():
	screen_central = $"/root/MainScene/CentralScreen"
	
#region Server signals
func start_lobby(_port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(_port, 4)
	if err:
		return false
	port = _port
	multiplayer.multiplayer_peer = peer
	create_player(1)  # Player for server
	
	print("listening on port " + str(port))
	return true
	
func join_lobby(_ip: String, _port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(_ip, _port)
	if err:
		return false
		
	ip = _ip
	port = _port
	multiplayer.multiplayer_peer = peer
	return true

func connected_to_server():
	# Request synchronization data from server
	pass

func peer_connected(id: int):
	if not multiplayer.is_server():
		return
	create_player(id)

func peer_disconnected(id: int):
	get_node("/root/GameController/Player" + str(id)).queue_free()
	
func disconnected():
	# TODO: Player cleanup
	print("disconnected from server")

# TODO: Maybe move this to a centralized NetworkingController
func resynchronize_client(client_id: int):
	# Sync player 
	# Sync prefabs
	PrefabController.refresh_networked_nodes.rpc_id(client_id, PrefabController.networked_nodes)
#endregion

#region Board setups
func standard_board_setup() -> GameSetup.BoardState:
	var board = GameSetup.BoardState.new(Vector2i(8, 8))
	var p1 = GameSetup.PlayerState.new()
	var p2 = GameSetup.PlayerState.new()
	
	p1.add_piece(ePieces.Pawn, Vector2i(0, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(1, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(2, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(3, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(4, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(5, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(6, 1), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Pawn, Vector2i(7, 1), ChessPiece.Orientation.South)
	
	p1.add_piece(ePieces.Queen, Vector2i(3, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.King, Vector2i(4, 0), ChessPiece.Orientation.South)
	
	p1.add_piece(ePieces.Rook, Vector2i(0, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Rook, Vector2i(7, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Knight, Vector2i(1, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Knight, Vector2i(6, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Bishop, Vector2i(2, 0), ChessPiece.Orientation.South)
	p1.add_piece(ePieces.Bishop, Vector2i(5, 0), ChessPiece.Orientation.South)
	
	p2.add_piece(ePieces.Pawn, Vector2i(0, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(1, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(2, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(3, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(4, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(5, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(6, 6), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Pawn, Vector2i(7, 6), ChessPiece.Orientation.North)
	
	p2.add_piece(ePieces.Queen, Vector2i(3, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.King, Vector2i(4, 7), ChessPiece.Orientation.North)
	
	p2.add_piece(ePieces.Rook, Vector2i(0, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Rook, Vector2i(7, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Knight, Vector2i(1, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Knight, Vector2i(6, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Bishop, Vector2i(2, 7), ChessPiece.Orientation.North)
	p2.add_piece(ePieces.Bishop, Vector2i(5, 7), ChessPiece.Orientation.North)
	
	board.players.append(p2)
	board.players.append(p1)
	
	return board
#endregion

#region Standard functions
func create_player(network_id: int):
	var player_path = "/root/GameController/Player" + str(network_id)
	var p = PrefabController.spawn_prefab("Player", player_path)
	PrefabController.register_networked_node("Player", player_path)
	p.network_id = network_id
	players_by_net_id[network_id] = p
	var gids = players_by_game_id
	for i in range(4):
		if not gids.has(i):
			print(i)
			p.game_id = i
			break

func start_game(json_game_settings: String, board_state: GameSetup.BoardState):
	if multiplayer.is_server:
		multiplayer.multiplayer_peer.refuse_new_connections = true
		# TODO: Bot takeover on disconnect
	game_settings = JsonClassConverter.json_string_to_class(GameSetup.GameSettings, json_game_settings)
	
	# Spawn board on all clients
	board = PrefabController.get_prefab("Board.Board").instantiate()
	board.visible = false  # Hide until fully loaded
	screen_central.add_child(board)
	board.name = "Board"
	
	# Initialize board with size and pieces
	load_board_state(board_state, players_by_game_id)
	
	# Set player states
	players_by_game_id[0].actions_remaining = 1
	
	# Wait until all players are loaded.
	player_loaded.rpc()
	
	pass
	#var p1 = Player.new(Player.PlayerID.Player1, self)
	#p1.name = "Oskar Stanislav"
	#add_child(p1)
	#player_slots[int(p1.id)].assigned_player = p1
	#var p2 = AIPlayer.new(Player.PlayerID.Player2, self)
	#p2.name = "Fyodor Danilski"
	#add_child(p2)
	#player_slots[int(p2.id)].assigned_player = p2
	#
	#self.players[Player.PlayerID.Player1] = p1
	#self.players[Player.PlayerID.Player2] = p2
	#var players: Array[Player] = [p1, p2]
	#p1.actions_remaining = 1
	#
	#load_board_state(standard_board_setup(), players)

func load_board_state(state: GameSetup.BoardState, players: Dictionary):
	if players.size() != state.players.size():
		print("Incorrect number of players for board state!")
		return
		
	# Update player states
	for player_num in state.players.size():
		var p = players[player_num]
		p.pieces = []
		p.actions_remaining = state.players[player_num].actions_remaining
	
	# Initialize board, if necessary
	if board == null:
		board = PrefabController.get_prefab("Board").instantiate()
		board.controller = self
		add_child(board)
		board.action_performed.connect(on_action)
		var grid = board.create_new_grid(state.size)
	
	# Spawn pieces
	board.clear_pieces()
	for player_num in state.players.size():
		var player_state: GameSetup.PlayerState = state.players[player_num]
		for piece in player_state.pieces:
			spawn_piece(piece.type, piece.position, piece.orientation, player_num)

func spawn_piece(piece_type: ePieces, coordinate: Vector2i, orientation: ChessPiece.Orientation, owned_by: int) -> ChessPiece:
	var piece: ChessPiece = PrefabController.get_prefab(piece_prefabs[piece_type]).instantiate()
	var cell = board.get_cell(coordinate)
	cell.occupying_piece = piece
	piece.Init(coordinate, orientation, owned_by, board)
	var p = players_by_game_id[owned_by]
	p.pieces.append(piece)
	return piece

func on_action(action: Board.GameAction):
	var id = action.player
	var p = players_by_net_id[id]
	p.actions_remaining -= 1
	
	# Is turn finished?
	if p.actions_remaining <= 0:
		var next_player = players_by_net_id[wrapi(int(id) + 1, 0, Player.players.size())]
		next_player.actions_remaining += 1

func is_action_legal(action: Board.GameAction):
	var p = players_by_game_id[action.player]
	if p.actions_remaining > 0:
		return true
	return false
#endregion
	
#region RPCs
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	players_loaded += 1
	if players_loaded == Player.players.size():
		board.visible = true
		print("loaded")
#endregion
	
enum ePieces {
	Pawn,
	Rook,
	Knight,
	Bishop,
	King,
	Queen,
}
