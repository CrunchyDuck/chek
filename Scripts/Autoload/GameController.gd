extends Node
# TODO: Handle player unable to move.
# TODO: Can only highlight your own pieces to see their moves.

var name_list = [
	"R. B. Ivy",
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
var board_playable: BoardPlayable
#var board_editable: BoardEditable
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
var screen_secondary: Control:
	get:
		return $"/root/MainScene/ViewportRightScreen/RightScreen"

var http: HTTPRequest
var fetching_ip: bool = false
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

var _game_settings: GameSettings = GameSettings.new()
var game_settings: GameSettings:
	get:
		return _game_settings
	set(value):
		if value == null:
			value = GameSettings.new()
		_game_settings = value
		confirm_start_with_extra_players = false
		on_game_settings_changed.emit(value)

# Last updated state
var _board_state: BoardBase.BoardState = BoardBase.BoardState.new()
var board_state: BoardBase.BoardState:
	get:
		return _board_state
	set(value):
		_board_state = value
		confirm_start_with_extra_players = false
		on_board_state_changed.emit(value)

var victory_condition: VictoryCondition
var turn_order: TurnOrder

var players_loaded: int = 0
var confirm_start_with_extra_players: bool = false

var stupid_players: Array[int] = []

signal on_board_state_changed(new_state: BoardBase.BoardState)
signal on_game_settings_changed(new_state: GameSettings)

signal on_game_start()
signal on_game_end()

signal on_turn_start(player: Player)
signal on_turn_taken(player: Player, action)
signal on_turn_end(player: Player)

const max_players: int = 4

func _ready():
	_get_references()
	# I'm not sure why I registered this originally - Maybe just insurance.
	# In any case it was causing GameController to be deleted at the end of some games.
	#PrefabController.register_networked_node("", get_path())
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.server_disconnected.connect(server_disconnected)
	
	character_name = name_list.pick_random()
	job_name = job_list.pick_random()
	
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_ip_response)
	
	on_game_end.connect(_on_game_end)
	on_game_start.connect(_on_game_start)
	
	on_turn_taken.connect(_on_turn_taken)
	$"/root/MainScene/Console/Lever".switched_off.connect(_on_main_power_off)
	
func _get_references():
	screen_central = $"/root/MainScene/ViewportMainScreen/MainScreen"
	
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
	
	MainScreenController.load_new_scene("Menus.Setup.Main")
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

func close_server():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	
	var to_destroy = Player.players.duplicate()
	for p in to_destroy:
		PrefabController.remove_networked_node(p.get_path())
		
	game_in_progress = false
	if board_playable:
		Helpers.destroy_node(board_playable)
		board_playable = null
	board_state = null
	game_settings = null
	victory_condition = null
	turn_order = null
	stupid_players = []
	players_loaded = 0
	confirm_start_with_extra_players = false
#endregion

#region Standard functions
func can_start_game() -> bool:
	var p_min = board_state.players.size()
	var p_count = Player.players.size()
	if not can_start_victory_condition():
		return false
	
	if p_count == p_min:
		return true
	elif p_count > p_min:
		if confirm_start_with_extra_players:
			return true
		var message = "Too many commanders. Press START again to confirm.\nRequired: {req}\nPresent: {have}"\
			.format({"req": str(p_min), "have": str(p_count)})
		MessageController.system_message(message)
		confirm_start_with_extra_players = true
		return false

	var content = "Not enough commanders. Find more.\nRequired: {req}\nPresent: {have}"\
		.format({"req": str(p_min), "have": str(p_count)})
	MessageController.system_message(content)
	return false
	
func get_ip():
	if fetching_ip:
		return
	var error = http.request("https://api.ipify.org")
	if error:
		push_warning("Could not get IP automatically. Error: " + str(error))
		return
	fetching_ip = true

func _ip_response(result, response_code, headers, body):
	if result != 0:
		push_warning("Failed to get IP address. Code: " + str(result) + " and " + str(response_code))
	public_ip = body.get_string_from_ascii()
	fetching_ip = false

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

func load_board_state(state: BoardBase.BoardState, players: Dictionary):
	# Update player states
	for player_num in state.players.size():
		var p = players[player_num]
		p.actions_remaining = state.players[player_num].actions_remaining
	
	# Initialize board_playable, if necessary
	if board_playable == null:
		board_playable = MainScreenController.load_new_scene("Board.BoardPlayable")
		board_playable.name = "Board"
	board_playable.visible = false  # Hide until fully loaded
	board_playable.load_state(state)
	
@rpc("any_peer", "call_local", "reliable")
func try_perform_action(game_action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	
	# Is the person trying to perform the action actually the owner?
	var player = players_by_game_id.get(game_action_data.player)
	if not (player != null and player == players_by_net_id[multiplayer.get_remote_sender_id()]):
		return
		
	var act = BoardPlayable.GameAction.deserialize(game_action_data)
	if game_settings.brave_and_stupid:
		if stupid_players.has(game_action_data.player):
			if act.type != BoardPlayable.eActionType.Attack and act.type != BoardPlayable.eActionType.AttackMove:
				return
	
	# Try this action on the server
	if perform_turn(game_action_data):
		perform_turn.rpc(game_action_data)

@rpc("authority", "call_remote", "reliable")
func perform_turn(game_action_data: Dictionary) -> bool:
	var action: BoardPlayable.GameAction = BoardPlayable.GameAction.deserialize(game_action_data)
	# Check if action is allowed with GameController/Player object.
	if not GameController.is_action_legal(action):
		return false
	
	var anything_performed = perform_action_chain(action)
	if anything_performed:
		on_turn_taken.emit(players_by_game_id[action.player], action)
		return true
	return false

func perform_action_chain(action: BoardPlayable.GameAction) -> bool:
	var anything_performed = false
	var current_action = action
	while current_action != null:
		match current_action.type:
			BoardPlayable.eActionType.Move:
				if not board_playable._move_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.Attack:
				if not board_playable._attack_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.AttackMove:
				if not board_playable._attack_to_cell(current_action.source, current_action.target):
					break
				anything_performed = true
				if not board_playable._move_to_cell(current_action.source, current_action.target):
					break
			BoardPlayable.eActionType.Spawn:
				pass
			BoardPlayable.eActionType.SwapPosition:
				if not board_playable._swap_cells(current_action.source, current_action.target):
					break
			_:
				assert(false, "Unhandled eActionType type in perform_action_chain")
		anything_performed = true
		current_action = current_action.next_action
	
	return anything_performed

func is_action_legal(action: BoardPlayable.GameAction):
	var p = players_by_game_id[action.player]
	if p.actions_remaining > 0:
		return true
	return false

@rpc("any_peer", "call_local", "reliable")
func skip_turn():
	if not game_settings.patience:
		return
	var network_id = multiplayer.get_remote_sender_id()
	var p = players_by_net_id[network_id]
	turn_order.turn_taken(p.game_id)
	
func find_brave_and_stupid() -> Array[int]:
	var stupid: Array[int] = [] 
	var p_gid = board_playable.pieces_by_game_id
	for gid in p_gid:
		var pieces: Array = p_gid[gid]
		for p in pieces:
			var acts = p._get_actions()
			var found_attack = false
			for act in acts:
				if act == null:
					continue
				if act.type == BoardPlayable.eActionType.Attack or act.type == BoardPlayable.eActionType.AttackMove:
					found_attack = true
					stupid.append(gid)
					break
			if found_attack:
				break
	return stupid
#endregion

#region Victory conditions
func can_start_victory_condition() -> bool:
	var vic = get_victory_condition(game_settings)
	if vic is VictoryPieceCapture:
		return vic.can_start_game(board_state, game_settings.victory_sacred_type, true)
	if vic is VictoryAnnihilation:
		return true
	
	MessageController.system_message("Unknown victory condition!")
	return false
	
func get_victory_condition(game_settings: GameSettings) -> VictoryCondition:
	if game_settings.victory_all_sacred or game_settings.victory_any_sacred:
		return VictoryPieceCapture.new(board_state, game_settings.victory_sacred_type, game_settings.victory_all_sacred)
	if game_settings.victory_annihilation:
		return VictoryAnnihilation.new()
	return null
	
func get_turn_order(game_settings: GameSettings, victory_condition: VictoryCondition) -> TurnOrder:
	if game_settings.turn_sequential:
		return TurnOrderSequential.new(players_by_game_id, victory_condition, game_settings.turns_at_a_time)
	return null

func perform_victory_and_defeat():
	var defeated = victory_condition.evaluate_defeat(board_playable.serialize(), game_settings)
		
	var victory = victory_condition.evaluate_victory(board_playable.serialize(), game_settings)
	if victory.size() > 0:
		var p = players_by_game_id[victory[0]]
		on_victory(p)
#endregion

#region Events
func on_victory(victor: Player):
	MessageController.system_message(victor.character_name + " is victorious!")
	
	board_playable.interaction_allowed = false
	
	var vs: VictoryScreen = MainScreenController.add_scene("Menus.VictoryScreen")
	vs.display_victor(victor.game_id)
	if multiplayer.is_server():
		for p in Player.players:
			p.send_player_stats()
	on_game_end.emit()
	
func _on_main_power_off():
	# Disconnect from the server and reset to default.
	close_server()

func _on_turn_taken(player: Player, action: BoardPlayable.GameAction):
	if game_settings.foreign_ground:
		board_playable.apply_fog_of_war(self.player.game_id)
	# Check for victory
	perform_victory_and_defeat()
	
	# Don't progress if the game is over
	if not game_in_progress:
		return
		
	if game_settings.brave_and_stupid:
		stupid_players = find_brave_and_stupid()
		
	# Progress turn order
	turn_order.turn_taken(action.player)

func _on_turn_start(started_for: Player):
	pass
	
func _on_game_start():
	game_in_progress = true
	multiplayer.multiplayer_peer.refuse_new_connections = true
	
func _on_game_end():
	game_in_progress = false
	players_loaded = 0
	confirm_start_with_extra_players = false
	multiplayer.multiplayer_peer.refuse_new_connections = false
	board_playable = null
	stupid_players = []
	for p in Player.players:
		if p.network_id == -1:
			Helpers.destroy_node(p)
	
func connected_to_server():
	try_create_player.rpc_id(1, character_name, job_name)
	PrefabController.request_refresh.rpc_id(1)
	MainScreenController.load_new_scene("Menus.Setup.Main")

func peer_disconnected(id: int):
	var player = players_by_net_id[id]
	player.defeated = true
	player.human_controlled = false
	player.network_id = -1
	if turn_order != null:
		turn_order.remove_player(player.game_id)
	
func server_disconnected():
	close_server()
	MainScreenController.instance.reset()
	MessageController.system_message("Disconnected from server")
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
		board_playable.visible = true
		Helpers.destroy_node(screen_central.get_node("GameLoading"))

func server_start_game():
	if not multiplayer.is_server():
		return
	if game_settings.formation_broken:
		board_state = BoardBase.randomize_piece_positions(board_state)
	if game_settings.b_team:
		board_state = BoardBase.randomize_piece_types(board_state)
	GameController.start_game.rpc(game_settings.serialize(), board_state.serialize())

@rpc("authority", "call_local", "reliable")
func start_game(json_game_settings: Dictionary, json_board_state: Dictionary):
	# make people like themselves
	for p in Player.players:
		p.friendly.append(p.game_id)
	
	MainScreenController.load_new_scene("Menus.GameLoading")
	
	# TODO: Bot takeover on disconnect
	game_settings = GameSettings.deserialize(json_game_settings)
	board_state = BoardBase.BoardState.deserialize(json_board_state)
	
	# Initialize board_playable with size and pieces
	load_board_state(board_state, players_by_game_id)
	
	if game_settings.foreign_ground:
		board_playable.apply_fog_of_war(player.game_id)
	if game_settings.patience:
		add_child(PatienceModifier.new())
	
	victory_condition = get_victory_condition(game_settings)
	turn_order = get_turn_order(game_settings, victory_condition)
	on_game_start.emit()
	# Wait until all players are loaded.
	player_loaded.rpc()
#endregion
