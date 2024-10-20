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
	
func _on_start():
	start_game.rpc(JsonClassConverter.class_to_json_string(game_settings))
	
@rpc("authority", "call_local", "reliable")
func start_game(json_game_settings: String):
	$"..".add_child(PrefabController.get_prefab("Menus.GameLoading").instantiate())
	queue_free()
	GameController.start_game(json_game_settings)

class GameSettings:
	var board_size: Vector2i = Vector2i(8, 8)

class BoardState:
	# Describes the state of the board
	var size: Vector2i
	var players: Array
	
	func _init(size: Vector2i):
		self.size = size
	
class PlayerState:
	var pieces: Array = []
	var actions_remaining: int = 0
	
	func add_piece(piece: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		pieces.append(PieceState.new(piece, position, orientation))

class PieceState:
	var type: GameController.ePieces
	var position: Vector2i
	var orientation: ChessPiece.Orientation
	# TODO: PieceID to make it easier to reference over network?
	
	func _init(type: GameController.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		self.type = type
		self.position = position
		self.orientation = orientation
