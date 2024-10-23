class_name GameSetup
extends Control

var game_settings

@onready
var button_start: Button = $Start

func _ready() -> void:
	button_start.pressed.connect(_on_start)
	if not multiplayer.is_server():
		button_start.disabled = true
	
	game_settings = GameSettings.new()
	print(get_path())
	
func _on_start():
	var jgs = game_settings.serialize()
	var jbs = GameController.standard_board_setup().serialize()
	start_game.rpc(jgs, jbs)
	
@rpc("authority", "call_local", "reliable")
func start_game(json_game_settings: Dictionary, json_board_state: Dictionary):
	print("here")
	$"..".add_child(PrefabController.get_prefab("Menus.GameLoading").instantiate())
	queue_free()
	GameController.start_game(json_game_settings, json_board_state)

class GameSettings:
	var board_size: Vector2i = Vector2i(8, 8)
	
	func serialize() -> Dictionary:
		var d = {}
		d["board_size"] = board_size
		return d
	
	static func deserialize(json_game_settings) -> GameSettings:
		var gs = GameSettings.new()
		gs.board_size = json_game_settings["board_size"]
		return gs

class BoardState:
	# Describes the state of the board
	var size: Vector2i
	var players: Array[GameSetup.PlayerState] = []
	
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
	
	func add_piece(piece: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		pieces.append(PieceState.new(piece, position, orientation))
		
	func serialize() -> Dictionary:
		var d = {}
		var _pieces = []
		for p in pieces:
			_pieces.append(p.serialize())
		d["pieces"] = _pieces
		d["actions_remaining"] = actions_remaining
		return d
		
	static func deserialize(json_player_state: Dictionary) -> PlayerState:
		var ps = PlayerState.new()
		ps.actions_remaining = json_player_state["actions_remaining"]
		for p in json_player_state["pieces"]:
			ps.pieces.append(PieceState.deserialize(p))
		
		return ps

class PieceState:
	var type: GameController.ePieces
	var position: Vector2i
	var orientation: ChessPiece.Orientation
	# TODO: PieceID to make it easier to reference over network?
	
	func _init(type: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		self.type = type
		self.position = position
		self.orientation = orientation
		
	func serialize() -> Dictionary:
		var d = {}
		d["type"] = type
		d["position"] = position
		d["orientation"] = orientation
		return d
	
	static func deserialize(json_piece_state: Dictionary) -> PieceState:
		return PieceState.new(
			json_piece_state["type"],
			json_piece_state["position"],
			json_piece_state["orientation"]
		)
