extends Node
class_name Player

static var players = {}

var board: BoardPlayable:
	get:
		return GameController.board_playable
var color: Color:
	get:
		var id = game_id
		if id == -1:
			id = 0
		return ColorController.player_primary_colors[id]

var player_type: Player.PlayerType = Player.PlayerType.None
var network_id: int = -1
var _game_id: int = -1
var game_id: int:
	get:
		return _game_id
	set(value):
		_game_id = value
var friendly: Array[int] = []
var actions_remaining: int = 0
var _character_name: String = ""
var character_name: String:
	get:
		return _character_name
	set(value):
		_character_name = value
		player_stats.name = value
var job_name: String

var human_controlled = true  # False if the player leaves, or if it's an AI
var defeated: bool = false  # Dead players are out of the game
var can_move: bool:
	get:
		return actions_remaining > 0

var init_state: BoardBase.PlayerState
var pieces: Array:
	get:
		if not board or not board.pieces_by_game_id.has(game_id):
			return []
		return board.pieces_by_game_id[game_id]

var player_stats: Player.PlayerStats
var received_stats: Player.PlayerStats  # Stats received on the network.
var action_start_time: float = 0

func _init():
	player_stats = Player.PlayerStats.new()
	players[self] = true

func _ready():
	GameController.on_game_start.connect(_on_game_start)
	
func _exit_tree() -> void:
	players.erase(self)
	
func _on_game_start():
	received_stats = null
	
func can_act() -> bool:
	for _piece in pieces:
		var _actions = _piece._get_actions()
		
		if _actions.size() == 0:
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

func send_player_stats():
	player_stats.name = character_name
	player_stats.player_num = game_id
	# TODO: This displays nan
	player_stats.average_turn_time = player_stats.total_turn_time / float(player_stats.turns_taken)
	
	player_stats.mistakes = randi_range(0, player_stats.pieces_lost)
	player_stats.tricks_pulled = randi_range(0, player_stats.pieces_killed)
	#player_stats.lights_on = $/root/MainScene/Console/MainLightButton/PowerCoordinator.on
	#player_stats.ventilation_on = $/root/MainScene/Console/Fan.on
	player_stats.happy = true if randf() < 0.5 else false
	player_stats.cheated = true if randf() < 0.5 else false
	receive_player_stats.rpc(player_stats.serialize())

@rpc("authority", "call_local", "reliable")
func receive_player_stats(stats: Dictionary):
	received_stats = PlayerStats.deserialize(stats)
	if VictoryScreen.instance != null:
		VictoryScreen.instance.display_stat(player_stats)

enum PlayerType {
	None,
	Human,
	AI,
}

	
class PlayerStats:
	var name = ""
	var player_num: int = 0
	var pieces_killed: int = 0
	var pieces_lost: int = 0
	var turns_taken: int = 0
	var distance_moved: float = 0
	var average_turn_time: float = 0
	var total_turn_time: float = 0  # Just used to calculate average turn time
	
	# useless stats, randomly chosen
	var mistakes: int = 0  # randomly chosen based on pieces lost
	var tricks_pulled: int = 0  # Randomly chosen based on pieces killed
	#var lights_on: bool = false
	#var ventilation_on: bool = false
	#var times_turned_monitor_off: int = 0
	#var competence: float = 0  # Factors in various stats arbitrarily.
	var happy: bool = false
	var cheated: bool = false
	
	func serialize() -> Dictionary:
		var d = {}
		d.name = name
		d.player_num = player_num
		d.pieces_killed = pieces_killed
		d.pieces_lost = pieces_lost
		d.turns_taken = turns_taken
		d.distance_moved = distance_moved
		d.average_turn_time = average_turn_time
		d.total_turn_time = total_turn_time
		
		d.mistakes = mistakes
		d.tricks_pulled = tricks_pulled
		#d.lights_on = lights_on
		#d.ventilation_on = ventilation_on
		#d.times_turned_monitor_off = times_turned_monitor_off
		#d.competence = competence
		d.happy = happy
		d.cheated = cheated
		return d
	
	static func deserialize(d: Dictionary) -> PlayerStats:
		var ps = PlayerStats.new()
		ps.name = d.name
		ps.player_num = d.player_num
		ps.pieces_killed = d.pieces_killed
		ps.pieces_lost = d.pieces_lost
		ps.turns_taken = d.turns_taken
		ps.distance_moved = d.distance_moved
		ps.average_turn_time = d.average_turn_time
		ps.total_turn_time = d.total_turn_time
		
		ps.mistakes = d.mistakes
		ps.tricks_pulled = d.tricks_pulled
		#ps.lights_on = d.lights_on
		#ps.ventilation_on = d.ventilation_on
		#ps.times_turned_monitor_off = d.times_turned_monitor_off
		#ps.competence = d.competence
		ps.happy = d.happy
		ps.cheated = d.cheated
		return ps
