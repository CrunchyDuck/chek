extends Node
class_name Player

static var players = {}

var board: BoardPlayable:
	get:
		return GameController.board
var color: Color:
	get:
		var id = game_id
		if id == -1:
			id = 0
		return ColorController.player_colors[id]

var player_type: Player.PlayerType = Player.PlayerType.None
var network_id: int = -1
var game_id: int = -1
var friendly: Array[int] = []
var actions_remaining: int = 0
var character_name: String
var job_name: String

var dead: bool = false  # Dead players are out of the game
var can_move: bool:
	get:
		return actions_remaining > 0

var init_state: BoardBase.PlayerState
var pieces: Array:
	get:
		if not board or not board.pieces_by_game_id.has(game_id):
			return []
		return board.pieces_by_game_id[game_id]

func _init():
	players[self] = true
	
func _exit_tree() -> void:
	players.erase(self)
	
	
func can_act() -> bool:
	for _piece in pieces:
		var _actions = _piece._get_actions()
		
		if _actions.size() == 0:
			print("here")
			continue
			
		for _act in _actions:
			if _act != null:
				return true
	
	return false

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
