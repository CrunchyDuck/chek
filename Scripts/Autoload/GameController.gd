extends Node

# TODO: Make use PrefabController
var piece_prefabs = {
	ePieces.Pawn: preload("res://Prefabs/Pieces/Pawn.tscn"),
	ePieces.Queen: preload("res://Prefabs/Pieces/Queen.tscn"),
	ePieces.King: preload("res://Prefabs/Pieces/King.tscn"),
	ePieces.Rook: preload("res://Prefabs/Pieces/Rook.tscn"),
	ePieces.Knight: preload("res://Prefabs/Pieces/Knight.tscn"),
	ePieces.Bishop: preload("res://Prefabs/Pieces/Bishop.tscn"),
}

var board: Board
var players: Dictionary = {}
@onready
var player_slots: Array[PlayerSlot] = [
	$"../Lobby/PlayerStates/PlayerSlot1",
	$"../Lobby/PlayerStates/PlayerSlot2",
	$"../Lobby/PlayerStates/PlayerSlot3",
	$"../Lobby/PlayerStates/PlayerSlot4",
]

var screen_central: Control

var port: int
var ip: String

var character_name: String = "O. Stanislav"

var game_settings: GameSetup.GameSettings

func _ready():
	_get_references()
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
func _get_references():
	screen_central = $"/root/MainScene/CentralScreen"
	
func start_lobby(_port: int) -> bool:
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(_port, 4)
	if err:
		return false
	port = _port
	multiplayer.multiplayer_peer = peer
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

func peer_connected(id: int):
	print("peer connected")

func peer_disconnected(id: int):
	print("peer disconnected")
	
func disconnected():
	print("disconnected from server")

func start_game(json_game_settings: String):
	if multiplayer.is_server:
		multiplayer.multiplayer_peer.refuse_new_connections = true
	game_settings = JsonClassConverter.json_string_to_class(GameSetup.GameSettings, json_game_settings)
	
	# Spawn board on all clients
	board = PrefabController.get_prefab("Board.Board").instantiate()
	board.visible = false  # Hide until fully loaded
	screen_central.add_child(board)
	board.name = "Board"
	
	# Initialize board with size and pieces
	
	# Set player states
	
	# Wait until all players are loaded.
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

func load_board_state(state: GameSetup.BoardState, players: Array[Player]):
	if players.size() != state.players.size():
		print("Incorrect number of players for board state!")
		return
	
	var grid = create_grid(state.size)
	for i in state.players.size():
		var player: Player = players[i]
		var player_state: GameSetup.PlayerState = state.players[i]
		for piece in player_state.pieces:
			spawn_piece(piece.type, grid[piece.position.y][piece.position.x], piece.orientation, player)
	board = PrefabController.get_prefab("Board").instantiate()
	add_child(board)
	board.Init(grid, self)
	board.action_performed.connect(on_action)

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

func create_grid(grid_size: Vector2i) -> Array:
	var cells = []
	for y in grid_size.y:
		var row = []
		for x in grid_size.x:
			var board_cell = PrefabController.get_prefab("BoardCell").instantiate()
			row.append(board_cell)
		cells.append(row)
	return cells

func spawn_piece(piece_type: ePieces, cell: BoardCell, orientation: ChessPiece.Orientation, owned_by: Player) -> ChessPiece:
	var piece: ChessPiece = piece_prefabs[piece_type].instantiate()
	cell.occupying_piece = piece
	piece.Init(cell, orientation, owned_by)
	owned_by.pieces.append(piece)
	return piece

func on_action(action: Board.GameAction):
	var id = action.player
	var p = players[id]
	p.actions_remaining -= 1
	
	# Is turn finished?
	if p.actions_remaining <= 0:
		var next_player = players[wrapi(int(id) + 1, 0, players.size())]
		next_player.actions_remaining += 1

func is_action_legal(action: Board.GameAction):
	var p = players[action.player]
	if p.actions_remaining > 0:
		return true
	return false

enum ePieces {
	Pawn,
	Rook,
	Knight,
	Bishop,
	King,
	Queen,
}
