class_name GameSetup
extends Control

var settings: GameSetup.GameSettings

@onready
var button_start: Button = $Start
@onready
var button_divine_wind: CheckBox = $Settings/DivineWind/CheckBox
@onready
var button_no_retreat: CheckBox = $Settings/NoRetreat/CheckBox

func _ready() -> void:
	button_start.pressed.connect(_on_start)
	if not multiplayer.is_server():
		button_start.disabled = true
	
	button_divine_wind.pressed.connect(_on_change)
	button_no_retreat.pressed.connect(_on_change)
	
	settings = gather_settings()

func _on_change():
	load_settings.rpc(gather_settings().serialize())
	
func _on_start():
	var settings = gather_settings()
	
	var jgs = settings.serialize()
	var jbs = GameController.standard_board_setup().serialize()
	GameController.start_game.rpc(jgs, jbs)
	
func gather_settings() -> GameSetup.GameSettings:
	var settings = GameSetup.GameSettings.new()
	settings.divine_wind = button_divine_wind.button_pressed
	settings.no_retreat = button_no_retreat.button_pressed
	return settings

@rpc("any_peer", "call_local", "reliable", 0)
func load_settings(json_settings: Dictionary):
	settings = GameSetup.GameSettings.deserialize(json_settings)
	button_divine_wind.button_pressed = settings.divine_wind
	button_no_retreat.button_pressed = settings.no_retreat
	
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
		d.pieces = _pieces
		d.actions_remaining = actions_remaining
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
		d.type = type
		d.position = position
		d.orientation = orientation
		return d
	
	static func deserialize(json_piece_state: Dictionary) -> PieceState:
		return PieceState.new(
			json_piece_state.type,
			json_piece_state.position,
			json_piece_state.orientation
		)
