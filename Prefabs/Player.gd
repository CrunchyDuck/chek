extends Node
class_name Player

static var players = {}

var board: Board:
	get:
		return GameController.board

var player_type: Player.PlayerType = Player.PlayerType.None
var network_id: int = -1
var game_id: int = -1
var friendly: Array[int] = []
var actions_remaining: int = 0
var character_name: String
var job_name: String

var can_move: bool:
	get:
		return actions_remaining > 0

var init_state: GameSetupRules.PlayerState
var pieces: Array[ChessPiece] = []

func _init():
	players[self] = true
	
func _exit_tree() -> void:
	players.erase(self)

func serialize() -> Dictionary:
	var d = {}
	d.player_type = self.player_type
	d.character_name = self.character_name
	d.job_name = self.job_name
	d.network_id = self.network_id
	d.game_id = self.game_id
	d.friendly = self.friendly
	d.actions_remaining = self.actions_remaining
	return d
	
func deserialize(data: Dictionary):
	self.player_type = data.player_type
	self.character_name = data.character_name
	self.job_name = data.job_name
	self.network_id = data.network_id
	self.game_id = data.game_id
	self.friendly = data.friendly
	self.actions_remaining = data.actions_remaining

func do_synchronize():
	if not multiplayer.is_server():
		return
	synchronize.rpc(serialize())
	
@rpc("any_peer", "call_remote", "reliable")
func request_synchronize():
	if not multiplayer.is_server():
		return
	synchronize.rpc_id(multiplayer.get_remote_sender_id(), serialize())

@rpc("authority", "call_remote", "reliable")
func synchronize(data: Dictionary):
	deserialize(data)

enum PlayerType {
	None,
	Human,
	AI,
}
