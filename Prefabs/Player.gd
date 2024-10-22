extends Node
class_name Player

static var players = {}

var controller: GameController
var board: Board:
	get:
		return controller.board

var player_type: Player.PlayerType = Player.PlayerType.None
var network_id: int = -1
var game_id: int = -1
var friendly: Array[int] = [game_id]
var actions_remaining: int = 0
var character_name: String

var can_move: bool:
	get:
		return actions_remaining > 0

var init_state: GameSetup.PlayerState
var pieces: Array[ChessPiece] = []

func _init():
	players[self] = true
	
func _exit_tree() -> void:
	players.erase(self)

func do_synchronize():
	if not multiplayer.is_server:
		return
	var dat = JsonClassConverter.class_to_json(PlayerData.new(player_type, network_id, game_id, friendly, actions_remaining))
	synchronize.rpc(dat)

@rpc("authority", "call_remote", "reliable")
func synchronize(data: Dictionary):
	var dat: Player.PlayerData = JsonClassConverter.json_to_class(Player.PlayerData, data)
	# Unpack
	player_type = dat.player_type
	network_id = dat.network_id
	game_id = dat.game_id
	friendly = dat.friendly
	actions_remaining = dat.actions_remaining

enum PlayerType {
	None,
	Human,
	AI,
}

class PlayerData:
	var player_type: Player.PlayerType
	var network_id: int
	var game_id: int
	var friendly: Array[int]
	var actions_remaining: int
	
	func _init(player_type: int, network_id: int, game_id: int, friendly: Array[int], actions_remaining: int):
		self.player_type = player_type
		self.network_id = network_id
		self.game_id = game_id
		self.friendly = friendly
		self.actions_remaining = actions_remaining
