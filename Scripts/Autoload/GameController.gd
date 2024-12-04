extends Node
# TODO: Handle player unable to move.
# TODO: Can only highlight your own pieces to see their moves.

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

var _game_settings: BoardBase.GameSettings = BoardBase.GameSettings.new()
var game_settings: BoardBase.GameSettings:
	get:
		return _game_settings
	set(value):
		if value == null:
			value = BoardBase.GameSettings.new()
		_game_settings = value
		confirm_start_with_extra_players = false
		on_game_settings_changed.emit(value)

# Used in setup
var _board_state: BoardBase.BoardState = BoardBase.BoardState.new()
var board_state: BoardBase.BoardState:
	get:
		return _board_state
	set(value):
		_board_state = value
		confirm_start_with_extra_players = false
		on_board_state_changed.emit(value)

var victory_condition: VictoryCondition

var players_loaded: int = 0
var confirm_start_with_extra_players: bool = false

signal on_board_state_changed(new_state)
signal on_game_settings_changed(new_state)

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
	
	GameController.screen_central.add_child(PrefabController.get_prefab("Menus.Setup.Main").instantiate())
	MessageController.add_message("OPENED PORT " + str(port))
	return true
	
# TODO: On join, synchronize game_state and board_state
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
	screen_central.add_child(PrefabController.get_prefab("Menus.Setup.Main").instantiate())

func peer_disconnected(id: int):
	Helpers.destroy_node(get_node("/root/GameController/Player" + str(id)))
	
func disconnected():
	# TODO: Player cleanup
	print("disconnected from server")
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

	var content = "Not enough commanders. Find more, or use state-of-art AI.\nRequired: {req}\nPresent: {have}"\
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
	
	# Initialize board, if necessary
	if board == null:
		board = PrefabController.get_prefab("Board.BoardPlayable").instantiate()
		screen_central.add_child(board)
		board.name = "Board"
	board.visible = false  # Hide until fully loaded
	board.load_state(state)
	
@rpc("any_peer", "call_local", "reliable")
func try_perform_action(game_action_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return
	
	# Is the person trying to perform the action actually the owner?
	var player = players_by_game_id.get(game_action_data.player)
	if not (player != null and player == players_by_net_id[multiplayer.get_remote_sender_id()]):
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
		on_turn_taken(action)
		return true
	return false

func perform_action_chain(action: BoardPlayable.GameAction) -> bool:
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
			BoardPlayable.eActionType.SwapPosition:
				if not board._swap_cells(current_action.source, current_action.target):
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
#endregion
	
#region Turn order
func turn_order_sequential(pid_just_acted: int):
	# Progress this player's action state.
	if pid_just_acted != -1:
		var p = players_by_game_id[pid_just_acted]
		p.actions_remaining -= 1
		p.player_stats.turns_taken += 1
		p.player_stats.total_turn_time += Time.get_ticks_msec() - p.action_start_time
		
		p.action_start_time = Time.get_ticks_msec()
		# Is turn finished?
		if p.actions_remaining > 0:
			p.action_start_time = Time.get_ticks_msec()
			return
		
	# Find next valid player
	for i in range(Player.players.size()):
		var pid = wrapi(int(pid_just_acted) + i + 1, 0, Player.players.size())
		var next_player = players_by_game_id[pid]
		if next_player.dead:
			continue
		if not next_player.can_act():
			var m = ColorController.color_text(next_player.character_name, next_player.color)
			m += " cannot act. Skipping turn."
			MessageController.add_message(m)
			continue
			
		next_player.actions_remaining = game_settings.turns_at_a_time
		next_player.action_start_time = Time.get_ticks_msec()
		return
	# TODO: Handle no player being able to act
#endregion

#region Victory conditions
func can_start_victory_condition() -> bool:
	var vic = get_victory_condition(game_settings)
	if vic is VictoryPieceCapture:
		return vic.can_start_game(board.serialize(), game_settings.victory_specific_type, true)
	return false
	
func get_victory_condition(game_settings: BoardBase.GameSettings) -> VictoryCondition:
	if game_settings.victory_specific_type:
		return VictoryPieceCapture.new(board.serialize(), game_settings.victory_specific_type, true)
	return null

func perform_victory_and_defeat():
	var defeated = victory_condition.evaluate_defeat(board.serialize(), game_settings)
	for d in defeated:
		var p = players_by_game_id[d]
		if p.defeated:
			continue
		p.defeated = true
		MessageController.system_message(p.character_name + " has been defeated!")
		
	var victory = victory_condition.evaluate_victory(board.serialize(), game_settings)
	if victory.size() > 0:
		var p = players_by_game_id[victory[0]]
		MessageController.system_message(p.character_name + " is victorious!")
		# TODO: Transition to victory screen
#endregion

#region Events
func on_turn_taken(action: BoardPlayable.GameAction):
	# Check for victory
	perform_victory_and_defeat()
	
	# Progress turn order
	if game_settings.turn_sequential:
		turn_order_sequential(action.player)
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
		Helpers.destroy_node(screen_central.get_node("GameLoading"))

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
	game_settings = BoardBase.GameSettings.deserialize(json_game_settings)
	var board_state = BoardBase.BoardState.deserialize(json_board_state)
	
	# Initialize board with size and pieces
	load_board_state(board_state, players_by_game_id)
	
	# Set player states
	turn_order_sequential(-1)
	victory_condition = get_victory_condition(game_settings)
	
	# Wait until all players are loaded.
	player_loaded.rpc()
#endregion
