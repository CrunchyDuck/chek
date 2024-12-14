class_name BoardBase
extends Control

#region Variables
var interaction_allowed: bool = true

const cell_size : Vector2i = Vector2i(64, 64)
const coordinates_size: Vector2 = cell_size
const cells_offset: Vector2 = cell_size / 2  # This allows their centered sprites to be positioned properly.

var grid_size: Vector2i:
	get:
		var y = grid.size()
		if y == 0:
			return Vector2i(0, 0)
		var x = grid[0].size()
		return Vector2i(x, y)
var bounds: Vector2:
	get:
		return grid_size * cell_size
var grid: Array[Array] = []  # x/y 2D array
var parent_size: Vector2:
	get:
		return $"..".size
		
var clipping_grid_size: Vector2i:
	get:
		return Vector2i(size - coordinates_size) / cell_size
var clipping_position_min: Vector2i
var clipping_position_max: Vector2i:
	get:
		return clipping_position_min + clipping_grid_size

var game_settings: GameSettings:
	get:
		return GameController.game_settings

@onready
var screen_controller: MainScreenController = $"/root/MainScene/ViewportMainScreen/MainScreenController"
@onready
var node_play_field: Control = $PlayField
@onready
var node_cells: Control = $PlayField/Cells
@onready
var node_pieces: Control = $PlayField/Pieces
@onready
var node_x_coordinates: BoardCoordinates = $XCoordinatesViewport
@onready
var node_y_coordinates: BoardCoordinates = $YCoordinatesViewport
		
var pieces_by_game_id: Dictionary:
	get:
		var _players = {}
		for _p in node_pieces.get_children():
			var _pid = _p.owned_by
			# Create players up to the ID needed.
			for _id in range(_players.size(), _pid + 1):
				_players[_id] = []
			_players[_pid].append(_p)
		return _players
#endregion

#region Built-in events
func _ready():
	node_play_field.clip_contents = true
	connect_buttons()
	node_x_coordinates.direction = Vector2(1, 0)
	node_y_coordinates.direction = Vector2(0, 1)

func _input(event):
	if event.is_action_pressed("SaveBoard"):
		save_state_to_file()
		
func _process(delta):
	# Bad form to update this every time rather than just on change,
	# But I was having issues with the size of control objects changing when their rendering is disabled.
	# And I'm past my deadline. :)
	_position_board()
	pass

func on_enable():
	connect_buttons()
	_set_button_activity()

func on_disable():
	_depower_buttons()
	disconnect_buttons()

func _exit_tree() -> void:
	_depower_buttons()
	
	disconnect_buttons()
#endregion

#region Board editing functions
func create_new_grid(_grid_size: Vector2i):
	for n in node_cells.get_children():
		Helpers.destroy_node(n)

	node_cells.position = cells_offset
	node_pieces.position = cells_offset
	grid = []
	for y in _grid_size.y:
		var row = []
		for x in _grid_size.x:
			var board_cell: BoardCell = PrefabController.get_prefab("Board.BoardCell").instantiate()
			board_cell.cell_coordinates = Vector2i(x, y)
			board_cell.board = self
			node_cells.add_child(board_cell)
			board_cell.position = cell_to_position(Vector2i(x, y))
			row.append(board_cell)
		grid.append(row)
		
	node_x_coordinates.create_coordinates(grid_size.x)
	node_y_coordinates.create_coordinates(grid_size.y)

func clear_pieces():
	for n in node_pieces.get_children():
		Helpers.destroy_node(n)

func spawn_piece_state(piece_state: BoardBase.PieceState) -> ChessPiece:
	return spawn_piece(piece_state.type, piece_state.position, piece_state.orientation, piece_state.player)

func spawn_piece(piece_type: ChessPiece.ePieces, coordinate: Vector2i, orientation: ChessPiece.Orientation, owned_by: int) -> ChessPiece:
	var piece: ChessPiece = PrefabController.get_prefab(ChessPiece.piece_prefabs[piece_type]).instantiate()
	var cell = get_cell(coordinate)
	var _op = cell.occupying_piece
	if _op:
		Helpers.destroy_node(_op)
	cell.occupying_piece = piece
	piece.Init(coordinate, orientation, owned_by, self)
	node_pieces.add_child(piece)
	piece.position = cell_to_position(coordinate)
	return piece
	
func serialize() -> BoardBase.BoardState:
	var bs = BoardBase.BoardState.new()
	bs.size = grid_size
	var players: Array[BoardBase.PlayerState] = []
	for piece in node_pieces.get_children():
		var p = piece.serialize()
		# Create players up to the ID needed.
		for id in range(players.size(), p.player + 1):
			players.append(BoardBase.PlayerState.new(id))
		players[p.player].pieces.append(p)
	
	bs.players = players
	return bs

func serialize_dict() -> Dictionary:
	return serialize().serialize()

static func randomize_piece_positions(state: BoardBase.BoardState) -> BoardBase.BoardState:
	var pieces: Array[BoardBase.PieceState] = []
	var blockers: Array[BoardBase.PieceState] = []
	var cells: Dictionary = {}
	
	for x in range(0, state.size.x-1):
		for y in range(0, state.size.y-1):
			cells[Vector2i(x, y)] = true
	
	for player in state.players:
		for piece in player.pieces:
			if piece.type == ChessPiece.ePieces.Blocker:
				blockers.append(piece)
			else:
				pieces.append(piece)
	
	for b in blockers:
		cells.erase(b.position)
	
	var cells_array = cells.keys()
	for p in pieces:
		var i = randi_range(0, cells_array.size() - 1)
		var new_coord = cells_array.pop_at(i)
		p.position = new_coord
		
	return state

static func randomize_piece_types(state: BoardBase.BoardState) -> BoardBase.BoardState:
	var pieces: Array[BoardBase.PieceState] = []
	var blockers: Array[BoardBase.PieceState] = []
	
	for player in state.players:
		for piece in player.pieces:
			if piece.type == ChessPiece.ePieces.Blocker:
				continue
			pieces.append(piece)
	
	for p in pieces:
		var i = randi_range(1, ChessPiece.ePieces.size() - 1)
		p.type = i
		
	return state

# TODO: Blockers don't seem to be loading in properly initially.
func load_state(state: BoardBase.BoardState):
	clear_pieces()
	create_new_grid(state.size)
	for player in state.players:
		for piece in player.pieces:
			spawn_piece_state(piece)
		
# TODO: Let players also save states to files.
func save_state_to_file():
	var gp = GamePreset.new(
		game_settings,
		serialize(),
		0,
		"NAME"
	)
	var save_file = FileAccess.open(SetupPreset.presets_path + "/NAME" + ".txt", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(gp.serialize(), " "))
	
func load_state_from_file(prefab: GamePreset):
	load_state(prefab.board_state)
	GameController.game_settings = prefab.game_settings
#endregion

#region Cell selection
# Get a cell's position within the Board object.
func cell_to_position(cell: Vector2i) -> Vector2:
	return cell * cell_size

func position_to_cell(_global_pos: Vector2) -> BoardCell:
	var _relative_pos = _global_pos - node_play_field.global_position
	if _relative_pos.x < 0 or _relative_pos.y < 0 or _relative_pos.x > node_play_field.size.x or _relative_pos.y > node_play_field.size.y:
		return null

	var x = (int(_relative_pos.x) / cell_size.x) + clipping_position_min.x
	var y = (int(_relative_pos.y) / cell_size.y) + clipping_position_min.y
	
	return grid[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
	if game_settings.round_earth:
		pos.x = wrapi(pos.x, 0, grid_size.x)
	if game_settings.polar_crossing:
		pos.y = wrapi(pos.y, 0, grid_size.y)
	
	if not is_coordinate_in_bounds(pos):
		return null
	
	return grid[pos.y][pos.x]

func is_coordinate_in_bounds(coordinate: Vector2i) -> bool:
	var x = coordinate.x
	var y = coordinate.y
	return x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y
	
#endregion

#region Positioning and clipping
func _position_board():
	_update_clipping_mask()
	var new_position = parent_size / 2
	new_position.x -= size.x / 2
	new_position.y -= size.y / 2
	position = new_position
	
	node_play_field.position = coordinates_size
	
	node_x_coordinates.position = Vector2(coordinates_size.x, 0)
	node_y_coordinates.position = Vector2(0, coordinates_size.y)

func _update_clipping_mask():
	var previous_clipping_min = clipping_position_min

	var div = Vector2i(parent_size) / cell_size
	var max_possible_size = div * cell_size
	# If board is smaller than the maximum size, shrink to fit the board.
	max_possible_size.x = min(max_possible_size.x, bounds.x + coordinates_size.x)
	max_possible_size.y = min(max_possible_size.y, bounds.y + coordinates_size.y)
	size = max_possible_size
	
	var _play_field_size = size - coordinates_size
	node_play_field.size = size - coordinates_size
	node_x_coordinates.size = Vector2(_play_field_size.x, coordinates_size.y)
	node_y_coordinates.size = Vector2(coordinates_size.x, _play_field_size.y)
	_move_clipping_position_min(previous_clipping_min)
	_set_button_activity()

func _move_clipping_position_min(_new_position: Vector2i):
	# If this position is out of bounds, lower it.
	var new_max = _new_position + clipping_grid_size
	_new_position.x -= max(new_max.x - grid_size.x, 0)
	_new_position.y -= max(new_max.y - grid_size.y, 0)
	
	clipping_position_min = _new_position
	var new_position = Vector2(-clipping_position_min * cell_size) + cells_offset
	node_cells.position = new_position
	node_pieces.position = new_position
	
	node_x_coordinates.scroll_to(clipping_position_min.x)
	node_y_coordinates.scroll_to(clipping_position_min.y)
	_set_button_activity()

func _set_button_activity():
	_depower_buttons()
	
	if clipping_position_min.y > 0:
		screen_controller.up_power.set_self(true)
	if clipping_position_min.x > 0:
		screen_controller.left_power.set_self(true)
	if clipping_position_max.x < grid_size.x:
		screen_controller.right_power.set_self(true)
	if clipping_position_max.y < grid_size.y:
		screen_controller.down_power.set_self(true)
	
# TODO: These lights flicker. While I think it looks neat, I should make it more controlled.
func _depower_buttons():
	var p = screen_controller.up_power
	p.set_self(false)
		
	p = screen_controller.right_power
	p.set_self(false)
		
	p = screen_controller.down_power
	p.set_self(false)
		
	p = screen_controller.left_power
	p.set_self(false)

func _move_clipping_up():
	if clipping_position_min.y <= 0:
		return
	var new_pos = clipping_position_min
	new_pos.y -= 1
	_move_clipping_position_min(new_pos)
	
func _move_clipping_right():
	if clipping_position_max.x >= grid_size.x:
		return
	var new_pos = clipping_position_min
	new_pos.x += 1
	_move_clipping_position_min(new_pos)
	
func _move_clipping_down():
	if clipping_position_max.y >= grid_size.y:
		return
	var new_pos = clipping_position_min
	new_pos.y += 1
	_move_clipping_position_min(new_pos)
	
func _move_clipping_left():
	if clipping_position_min.x <= 0:
		return
	var new_pos = clipping_position_min
	new_pos.x -= 1
	_move_clipping_position_min(new_pos)
#endregion

#region Scroll button control
func connect_buttons():
	if screen_controller.up_button.on_pressed.is_connected(_move_clipping_up):
		return
	
	screen_controller.up_button.on_pressed.connect(_move_clipping_up)
	screen_controller.right_button.on_pressed.connect(_move_clipping_right)
	screen_controller.down_button.on_pressed.connect(_move_clipping_down)
	screen_controller.left_button.on_pressed.connect(_move_clipping_left)

func disconnect_buttons():
	if not screen_controller.up_button.on_pressed.is_connected(_move_clipping_up):
		return
	
	screen_controller.up_button.on_pressed.disconnect(_move_clipping_up)
	screen_controller.right_button.on_pressed.disconnect(_move_clipping_right)
	screen_controller.down_button.on_pressed.disconnect(_move_clipping_down)
	screen_controller.left_button.on_pressed.disconnect(_move_clipping_left)
#endregion

#region Networking functions
func do_synchronize():
	if not multiplayer.is_server():
		return
	synchronize.rpc(serialize_dict())
	
@rpc("authority", "call_local", "reliable")
func synchronize(json_board_state: Dictionary):
	var bs = BoardBase.BoardState.deserialize(json_board_state)
	load_state(bs)
	GameController.board_state = bs

@rpc("any_peer", "call_local", "reliable")
func request_synchronize():
	if not multiplayer.is_server():
		return
	synchronize.rpc_id(multiplayer.get_remote_sender_id(), serialize_dict())
#endregion

#region Classes
class BoardState:
	# Describes the state of the board
	var size: Vector2i = Vector2i(8, 8)
	var players: Array[BoardBase.PlayerState] = []
	
	func serialize() -> Dictionary:
		var _players = []
		for p in players:
			_players.append(p.serialize())
		
		var d = {}
		d.size_x = size.x
		d.size_y = size.y
		d.players = _players
		return d
		
	static func deserialize(json_board_state: Dictionary) -> BoardState:
		var bs = BoardState.new()
		bs.size = Vector2i(json_board_state.size_x, json_board_state.size_y)
		for p in json_board_state.players:
			bs.players.append(PlayerState.deserialize(p))
		
		return bs
	
class PlayerState:
	var pieces: Array = []
	var actions_remaining: int = 0
	var id: int
	
	func _init(id: int):
		self.id = id
	
	func add_piece(piece: ChessPiece.ePieces, position: Vector2i, orientation: ChessPiece.Orientation):
		pieces.append(PieceState.new(piece, position, orientation, id))
		
	func pieces_by_type() -> Dictionary:
		var d = {}
		for p in pieces:
			if not d.has(p.type):
				d[p.type] = []
			d[p.type].append(p)
		return d
		
	func serialize() -> Dictionary:
		var d = {}
		var _pieces = []
		for p in pieces:
			_pieces.append(p.serialize())
		d.pieces = _pieces
		d.actions_remaining = actions_remaining
		d.id = id
		return d
		
	static func deserialize(json_player_state: Dictionary) -> PlayerState:
		var ps = PlayerState.new(json_player_state.id)
		ps.actions_remaining = json_player_state["actions_remaining"]
		for p in json_player_state["pieces"]:
			ps.pieces.append(PieceState.deserialize(p))
		return ps

class PieceState:
	var type: ChessPiece.ePieces
	var position: Vector2i
	var orientation: ChessPiece.Orientation
	var player: int
	# TODO: PieceID to make it easier to reference over network?
	
	func _init(type: ChessPiece.ePieces, position: Vector2i, orientation: ChessPiece.Orientation, player: int):
		self.type = type
		self.position = position
		self.orientation = orientation
		self.player = player
		
	func serialize() -> Dictionary:
		var d = {}
		d.type = type
		d.position_x = position.x
		d.position_y = position.y
		d.orientation = orientation
		d.player = player
		return d
	
	static func deserialize(json_piece_state: Dictionary) -> PieceState:
		return PieceState.new(
			json_piece_state.type,
			Vector2i(json_piece_state.position_x, json_piece_state.position_y),
			json_piece_state.orientation,
			json_piece_state.player,
		)

class GamePreset:
	var game_settings: GameSettings
	var board_state: BoardBase.BoardState
	var complexity: int
	var name: String
	var players: int
	
	func _init(_game_settings: GameSettings, _board_state: BoardBase.BoardState, _complexity: int, _name: String):
		game_settings = _game_settings
		board_state = _board_state
		complexity = _complexity
		name = _name
		players = _board_state.players.size()
	
	func serialize() -> Dictionary:
		var d = {}
		d.game_settings = game_settings.serialize()
		d.board_state = board_state.serialize()
		d.complexity = complexity
		d.name = name
		d.players = players
		return d
	
	static func deserialize(_game_prefab: Dictionary) -> GamePreset:
		return GamePreset.new(
			GameSettings.deserialize(_game_prefab.game_settings),
			BoardBase.BoardState.deserialize(_game_prefab.board_state),
			_game_prefab.complexity,
			_game_prefab.name
		)
#endregion
