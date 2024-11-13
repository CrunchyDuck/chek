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
	"C. Bolyek",
	"A. Jaynee-Shiko",
	"O. Rorerez",
	"A. Danilski",
	"D. Eshuis",
	"P. Achu",
	"A. Avraam",
	"G. Schuyler",
]

var job_list = [
	"General Specialist",
	"Archeological Technician",
	"Post-Mortem Medic",
	"Ground Pilot",
	"DisDeReEncrypter",
	"Pigeon Expert",
	"Communications Jammer",
	"Anthropromorphic Suit Constructor",
	"Poison Tester",
	"Un-Rescuer",
	"Bot Botanist",
	"Best Boy Mine Layer",
	"Police Police",
	"Spy",
	"Spy Spy",
	"Spy Spy Spy",
	"Emergency Reserve Chef",
	"Paranormal Normalizer",
	"Future Historian",
	"Proper Propaganda Propagator",
]

var game_in_progress: bool = false
var board: BoardPlayable
var players_by_net_id: Dictionary:
	get:
		var d = {}
		for p in Player.players.keys():
			d[p.network_id] = p
		return d
var players_by_game_id: Dictionary:
	get:
		var d = {}
		for p in Player.players.keys():
			d[p.game_id] = p
		return d

var screen_central: Control

var http
var public_ip: String
var port: int
var ip: String

var player: Player:
	get:
		if GameController.players_by_net_id.has(multiplayer.get_unique_id()):
			return GameController.players_by_net_id[multiplayer.get_unique_id()]
		return null
var game_id: int:
	get:
		if player != null:
			return player.game_id
		return 0
var character_name: String
var job_name: String

var game_settings: GameController.GameSettings
var board_state: GameController.BoardState
var players_loaded: int = 0

const max_players: int = 4

func _ready():
	_get_references()
	PrefabController.register_networked_node("", get_path())
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	character_name = name_list.pick_random()
	job_name = job_list.pick_random()
	
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_ip_response)
	
func _get_references():
	screen_central = $"/root/MainScene/ViewportCentralScreen/CentralScreen"
	
func _process(_delta: float) -> void:
	if Engine.get_frames_drawn() % 600 == 0:
		get_ip()
		
#region Server events
func start_lobby(_port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(_port, max_players)
	if err:
		return false
	port = _port
	multiplayer.multiplayer_peer = peer
	create_player(1, character_name, job_name)  # Player for server
	
	MessageController.add_message("OPENED PORT " + str(port))
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
	try_create_player.rpc_id(1, character_name, job_name)
	PrefabController.request_refresh.rpc_id(1)

func peer_disconnected(id: int):
	get_node("/root/GameController/Player" + str(id)).queue_free()
	
func disconnected():
	# TODO: Player cleanup
	print("disconnected from server")
#endregion

#region Board configurations
func standard_board_setup() -> GameController.BoardState:
	var board = GameController.BoardState.new(Vector2i(8, 8))
	var p1 = GameController.PlayerState.new(0)
	var p2 = GameController.PlayerState.new(1)
	
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
func get_ip():
	var error = http.request("https://api.ipify.org")
	if error:
		push_warning("Could not get IP automatically. Error: " + str(error))
		return

func _ip_response(result, response_code, headers, body):
	if result != 0:
		push_warning("Failed to get IP address. Code: " + str(result) + " and " + str(response_code))
	public_ip = body.get_string_from_ascii()

func create_player(network_id: int, character_name: String, job_name: String):
	if not multiplayer.is_server():
		return
	var player_path = "/root/GameController/Player" + str(network_id)
	var p = PrefabController.spawn_prefab("Player", player_path)
	p.network_id = network_id
	p.character_name = character_name
	p.job_name = job_name
	var gids = players_by_game_id
	for i in range(max_players):
		if not gids.has(i):
			p.game_id = i
			break
			
	var m = ColorControllers.color_by_player(character_name + ", " + job_name, p.game_id)
	m += " has connected"
	MessageController.add_message.rpc(m)
	PrefabController.register_networked_node.rpc("Player", player_path)

func load_board_state(state: GameController.BoardState, players: Dictionary):
	if players.size() != state.players.size():
		print("Incorrect number of players for board state!")
		#return
		
	# Update player states
	for player_num in state.players.size():
		var p = players[player_num]
		p.pieces.clear()
		p.actions_remaining = state.players[player_num].actions_remaining
	
	# Initialize board, if necessary
	if board == null:
		var b = PrefabController.get_prefab("Board.Board").instantiate()
		screen_central.add_child(b)
		b.set_script(BoardPlayable)
		board = b
		board.visible = false  # Hide until fully loaded
		board.name = "Board"
		board.create_new_grid(state.size)
	
	# Spawn pieces
	board.clear_pieces()
	for player_num in state.players.size():
		var player_state: GameController.PlayerState = state.players[player_num]
		for piece in player_state.pieces:
			spawn_piece(piece.type, piece.position, piece.orientation, player_num)

func spawn_piece(piece_type: ePieces, coordinate: Vector2i, orientation: ChessPiece.Orientation, owned_by: int) -> ChessPiece:
	var piece: ChessPiece = PrefabController.get_prefab(piece_prefabs[piece_type]).instantiate()
	var cell = board.get_cell(coordinate)
	cell.occupying_piece = piece
	piece.Init(coordinate, orientation, owned_by, board)
	board.node_pieces.add_child(piece)
	piece.position = board.cell_to_position(coordinate)
	var p = players_by_game_id[owned_by]
	p.pieces.append(piece)
	return piece

@rpc("any_peer", "call_local", "reliable")
func try_perform_action(game_action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	
	# Is the person trying to perform the action actually the owner?
	var player = players_by_game_id.get(game_action_data.player)
	if not (player != null and player == players_by_net_id[multiplayer.get_remote_sender_id()]):
		return
	
	# Try this action on the server
	if perform_action(game_action_data):
		perform_action.rpc(game_action_data)

@rpc("authority", "call_remote", "reliable")
func perform_action(game_action_data: Dictionary) -> bool:
	var action: BoardPlayable.GameAction = BoardPlayable.GameAction.deserialize(game_action_data)
	# Check if action is allowed with GameController/Player object.
	if not GameController.is_action_legal(action):
		return false
	
	var anything_performed = false
	var current_action = action
	while current_action != null:
		match current_action.type:
			BoardPlayable.eActionType.Move:
				if not board._move_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.Attack:
				if not board._attack_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.AttackMove:
				if not board._attack_to_cell(current_action.source, current_action.target):
					break
				anything_performed = true
				if not board._move_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.Spawn:
				pass
			_:
				assert(false, "Unhandled eActionType type in perform_action")
		anything_performed = true
		current_action = current_action.next_action
		
	if anything_performed:
		on_action(action)
		return true
	return false

func is_action_legal(action: BoardPlayable.GameAction):
	var p = players_by_game_id[action.player]
	if p.actions_remaining > 0:
		return true
	return false
#endregion
	
#region Events
func on_action(action: BoardPlayable.GameAction):
	var id = action.player
	var p = players_by_game_id[id]
	p.actions_remaining -= 1
	
	# Is turn finished?
	if p.actions_remaining <= 0:
		var next_player = players_by_game_id[wrapi(int(id) + 1, 0, Player.players.size())]
		next_player.actions_remaining += 1
#endregion
	
#region RPCs
# I don't like that this is here. I'd rather it be on the Player, or somewhere else more general.
@rpc("any_peer", "call_local", "reliable")
func try_create_player(character_name: String, job_name: String):
	if not multiplayer.is_server():
		return
	var network_id = multiplayer.get_remote_sender_id()
	if players_by_net_id.has(network_id):
		print("Tried to create player that already exists.")
	create_player(network_id, character_name, job_name)
	
	
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	players_loaded += 1
	if players_loaded == Player.players.size():
		board.visible = true
		screen_central.get_node("GameLoading").queue_free()


@rpc("authority", "call_local", "reliable")
func start_game(json_game_settings: Dictionary, json_board_state: Dictionary):
	game_in_progress = true
	# make people like themselves
	for p in Player.players:
		p.friendly.append(p.game_id)
		
	for n in screen_central.get_children():
		screen_central.remove_child(n)
		n.queue_free()
	screen_central.add_child(PrefabController.get_prefab("Menus.GameLoading").instantiate())

	if multiplayer.is_server:
		multiplayer.multiplayer_peer.refuse_new_connections = true
		# TODO: Bot takeover on disconnect
	game_settings = GameController.GameSettings.deserialize(json_game_settings)
	var board_state = GameController.BoardState.deserialize(json_board_state)
	
	# Spawn board on all clients
	
	# Initialize board with size and pieces
	load_board_state(board_state, players_by_game_id)
	
	# Set player states
	players_by_game_id[0].actions_remaining = 1
	
	# Wait until all players are loaded.
	player_loaded.rpc()
#endregion


class GameSettings:
	var board_size: Vector2i = Vector2i(8, 8)
	
	var divine_wind: bool = false
	var no_retreat: bool = false
	
	func serialize() -> Dictionary:
		var d = {}
		d.board_size = board_size
		d.divine_wind = divine_wind
		d.no_retreat = no_retreat
		return d
	
	static func deserialize(json_game_settings) -> GameSettings:
		var gs = GameSettings.new()
		gs.board_size = json_game_settings.board_size
		gs.divine_wind = json_game_settings.divine_wind
		gs.no_retreat = json_game_settings.no_retreat
		
		return gs

class BoardState:
	# Describes the state of the board
	var size: Vector2i
	var players: Array[GameController.PlayerState] = []
	
	func _init(size: Vector2i):
		self.size = size
	
	func serialize() -> Dictionary:
		var d = {}
		d["size"] = size
		var _players = []
		for p in players:
			_players.append(p.serialize())
		d["players"] = _players
		return d
		
	static func deserialize(json_board_state: Dictionary) -> BoardState:
		var bs = BoardState.new(json_board_state["size"])
		for p in json_board_state["players"]:
			bs.players.append(PlayerState.deserialize(p))
		
		return bs
	
class PlayerState:
	var pieces: Array = []
	var actions_remaining: int = 0
	var id: int
	
	func _init(id: int):
		self.id = id
	
	func add_piece(piece: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		pieces.append(PieceState.new(piece, position, orientation, id))
		
	func serialize() -> Dictionary:
		var d = {}
		var _pieces = []
		for p in pieces:
			_pieces.append(p.serialize())
		d.pieces = _pieces
		d.actions_remaining = actions_remaining
		d.id = id
		return d
		
	static func deserialize(json_player_state: Dictionary) -> PlayerState:
		var ps = PlayerState.new(json_player_state.id)
		ps.actions_remaining = json_player_state["actions_remaining"]
		for p in json_player_state["pieces"]:
			ps.pieces.append(PieceState.deserialize(p))
		return ps

class PieceState:
	var type: GameController.ePieces
	var position: Vector2i
	var orientation: ChessPiece.Orientation
	var player: int
	# TODO: PieceID to make it easier to reference over network?
	
	func _init(type: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation, player: int):
		self.type = type
		self.position = position
		self.orientation = orientation
		self.player = player
		
	func serialize() -> Dictionary:
		var d = {}
		d.type = type
		d.position = position
		d.orientation = orientation
		d.player = player
		return d
	
	static func deserialize(json_piece_state: Dictionary) -> PieceState:
		return PieceState.new(
			json_piece_state.type,
			json_piece_state.position,
			json_piece_state.orientation,
			json_piece_state.player,
		)


enum ePieces {
	Pawn,
	Rook,
	Knight,
	Bishop,
	King,
	Queen,
}
