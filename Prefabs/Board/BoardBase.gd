class_name BoardBase
extends Control

func _input(event):
	if event.is_action_pressed("SaveBoard"):
		save_state_to_file()

#region Variables
var grid_size: Vector2i:
	get:
		var y = grid.size()
		if y == 0:
			return Vector2i(0, 0)
		var x = grid[0].size()
		return Vector2i(x, y)
const cell_size : Vector2i = Vector2i(64, 64)
var bounds: Vector2:
	get:
		return grid_size * cell_size
var grid: Array[Array] = []  # x/y 2D array
var board_size: Vector2:
	get:
		return Vector2(grid_size * cell_size)
var parent_size: Vector2:
	get:
		return $"..".size

var game_settings: BoardBase.GameSettings:
	get:
		return GameController.game_settings

var node_cells: Control:
	get:
		return $Cells
var node_pieces: Control:
	get:
		return $Pieces
		
var pieces_by_game_id: Dictionary:
	get:
		var _players = {}
		for _p in node_pieces.get_children():
			var _pid = _p.player
			# Create players up to the ID needed.
			for _id in range(_players.size(), _pid + 1):
				_players[_id] = []
			_players[_pid].append(_p)
		return _players
#endregion

func _ready():
	clip_contents = true

#region Board editing functions
func create_new_grid(_grid_size: Vector2i) -> Array[Array]:
	for n in node_cells.get_children():
		n.queue_free()

	node_cells.position = Vector2(cell_size) / 2
	node_pieces.position = Vector2(cell_size) / 2
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
	return grid

func clear_pieces():
	for n in node_pieces.get_children():
		node_pieces.remove_child(n)
		n.queue_free()

func spawn_piece_state(piece_state: BoardBase.PieceState) -> ChessPiece:
	return spawn_piece(piece_state.type, piece_state.position, piece_state.orientation, piece_state.player)

func spawn_piece(piece_type: ChessPiece.ePieces, coordinate: Vector2i, orientation: ChessPiece.Orientation, owned_by: int) -> ChessPiece:
	var piece: ChessPiece = PrefabController.get_prefab(ChessPiece.piece_prefabs[piece_type]).instantiate()
	var cell = get_cell(coordinate)
	var _op = cell.occupying_piece
	if _op:
		_op.queue_free()
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

func load_state(state: BoardBase.BoardState):
	clear_pieces()
	create_new_grid(state.size)
	for player in state.players:
		for piece in player.pieces:
			spawn_piece_state(piece)
		
func save_state_to_file():
	var b = serialize_dict()
	var save_file = FileAccess.open("user://BoardState.bbb", FileAccess.WRITE)
	save_file.store_line(JSON.stringify(b))
#endregion

#region Cell selection
func grid_to_position(x: int, y: int) -> Vector2:
	var pos: Vector2
	pos.x += x * cell_size.x
	pos.y += y * cell_size.y
	return pos

func cell_to_position(cell: Vector2i) -> Vector2:
	return cell * cell_size

func position_to_cell(pos: Vector2) -> BoardCell:
	# Relative to our position
	pos -= global_position
	if pos.x < 0 or pos.y < 0 or pos.x > bounds.x or pos.y > bounds.y:
		return null
	var x = int(pos.x) / cell_size.x
	var y = int(pos.y) / cell_size.y
	
	return grid[y][x]

func get_cell(pos: Vector2i) -> BoardCell:
	#if game_settings.wrapx:
	pos.x = wrapi(pos.x, 0, grid_size.x)
	pos.y = wrapi(pos.y, 0, grid_size.y)
	
	if not is_coordinate_in_bounds(pos):
		return null
	
	return grid[pos.y][pos.x]

func is_coordinate_in_bounds(coordinate: Vector2i) -> bool:
	var x = coordinate.x
	var y = coordinate.y
	return x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y
#endregion

func _position_board():
	_update_clipping_mask()
	var new_position = parent_size / 2
	new_position.x -= size.x / 2
	new_position.y -= size.y / 2
	position = new_position

func _update_clipping_mask():
		var div = Vector2i(parent_size) / cell_size
		var max_possible_size = div * cell_size
		# If board is smaller than the maximum size, shrink to fit the board.
		max_possible_size.x = min(max_possible_size.x, board_size.x)
		max_possible_size.y = min(max_possible_size.y, board_size.y)
		size = max_possible_size
		
#region Classes
class GameSettings:
	var board_size: Vector2i = Vector2i(8, 8)
	
	#region Victory conditions
	# Total number of pieces remaining
	var victory_total_limit: bool = false
	var victory_total_count: int = 0
	
	# Specific piece remaining
	var victory_specific_limit: bool = false
	var victory_specific_type: ChessPiece.ePieces = 0
	var victory_lose_any: bool = false
	var victory_lose_all: bool = false
	#endregion
	
	#region Turn rules
	var turn_sequential: bool = true
	var turns_concurrent: bool = false  # Turns are all taken at the same time
	var turns_at_a_time: int = 1
	
	var turn_bullet_chess: bool = false # Players have a time limit. They lose if it reaches 0.
	var turn_bullet_limit: float = 0
	
	var turn_queue: bool = false  # Players all queue up their moves, and all moves happen at once.
	var turn_queue_time: float = 0
	
	var turn_timed: bool = false  # Players take their turns after their cooldown runs out.
	var turn_cooldown: float = 0
	#endregion
	
	var divine_wind: bool = false
	var no_retreat: bool = false
	
	func serialize() -> Dictionary:
		var d = {}
		d.board_size = board_size
		d.divine_wind = divine_wind
		d.no_retreat = no_retreat
		
		d.victory_total_limit = victory_total_limit
		d.victory_total_count = victory_total_count
		
		d.victory_specific_limit = victory_specific_limit
		d.victory_specific_type = victory_specific_type
		d.victory_lose_any = victory_lose_any
		d.victory_lose_all = victory_lose_all

		d.turn_sequential = turn_sequential
		d.turns_concurrent = turns_concurrent
		d.turns_at_a_time = turns_at_a_time
		
		d.turn_bullet_chess = turn_bullet_chess
		d.turn_bullet_limit = turn_bullet_limit
		
		d.turn_queue = turn_queue
		d.turn_queue_time = turn_queue_time
		
		d.turn_timed = turn_timed
		d.turn_cooldown = turn_cooldown
		return d
	
	static func deserialize(json_game_settings) -> GameSettings:
		var gs = GameSettings.new()
		gs.board_size = json_game_settings.board_size
		gs.divine_wind = json_game_settings.divine_wind
		gs.no_retreat = json_game_settings.no_retreat
		
		gs.victory_total_limit = json_game_settings.victory_total_limit
		gs.victory_total_count = json_game_settings.victory_total_count
		
		gs.victory_specific_limit = json_game_settings.victory_specific_limit
		gs.victory_specific_type = json_game_settings.victory_specific_type
		gs.victory_lose_any = json_game_settings.victory_lose_any
		gs.victory_lose_all = json_game_settings.victory_lose_all

		gs.turn_sequential = json_game_settings.turn_sequential
		gs.turns_concurrent = json_game_settings.turns_concurrent
		gs.turns_at_a_time = json_game_settings.turns_at_a_time
		
		gs.turn_bullet_chess = json_game_settings.turn_bullet_chess
		gs.turn_bullet_limit = json_game_settings.turn_bullet_limit
		
		gs.turn_queue = json_game_settings.turn_queue
		gs.turn_queue_time = json_game_settings.turn_queue_time
		
		gs.turn_timed = json_game_settings.turn_timed
		gs.turn_cooldown = json_game_settings.turn_cooldown
		
		return gs

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
#endregion
