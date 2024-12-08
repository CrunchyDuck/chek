class_name ChessPiece
extends Sprite2D

enum Orientation {
	# South is the start as y is down in Godot.
	South = 0,
	West = 90,
	North = 180,
	East = 270,
}

enum ePieces {
	Blocker,
	Pawn,
	Rook,
	Knight,
	Bishop,
	Queen,
	King,
	Beast,
	Bomber,
	Hologram,
	Shifter,
	Czeker,
	Youth,
}

static var piece_prefabs = {
	ePieces.Blocker: "Pieces.Blocker",
	ePieces.Pawn: "Pieces.Pawn",
	ePieces.Queen: "Pieces.Queen",
	ePieces.King: "Pieces.King",
	ePieces.Rook: "Pieces.Rook",
	ePieces.Knight: "Pieces.Knight",
	ePieces.Bishop: "Pieces.Bishop",
	ePieces.Beast: "Pieces.Beast",
	ePieces.Bomber: "Pieces.Bomber",
	ePieces.Hologram: "Pieces.Hologram",
	ePieces.Shifter: "Pieces.Shifter",
	ePieces.Czeker: "Pieces.Czeker",
	ePieces.Youth: "Pieces.Youth",
}

var node_sprite: Sprite2D = self
# Defined in children. Abstracts don't work well in godot.
# var piece_description = ""

var piece_type: ChessPiece.ePieces
var board: BoardBase
var coordinates: Vector2i
var move_count: int = 0
var _owned_by: int
var owned_by: int:
	get:
		return _owned_by
	set(value):
		_owned_by = value
		update_color()
		
var _orientation: ChessPiece.Orientation = Orientation.North
var orientation: ChessPiece.Orientation:
	get:
		return _orientation
	set(value):
		_orientation = value
		node_sprite.rotation_degrees = float(orientation - 180)

var owned_by_player: Player:
	get:
		if owned_by == null or board == null:
			return null
		return GameController.players_by_game_id.get(owned_by)
		
var in_cell: BoardCell:
	get:
		if board == null:
			return null
		return board.get_cell(coordinates)

signal on_kill(killer, victim)
signal on_killed(killer, victim)

signal on_reached_end_of_board()

# TODO: Make pieces use different spite based on owner
func Init(_coordinates: Vector2i, _orientation: ChessPiece.Orientation, _owned_by: int, _board: BoardBase) -> void:
	self.coordinates = _coordinates
	self.orientation = _orientation
	self.owned_by = _owned_by
	self.board = _board
	on_killed.connect(_on_killed)
	on_kill.connect(_on_kill)

# This lets us rotate vectors to be from the perspective of its team.
# y = 1 for the top of the board (Black, in a normal game), will be y = -1 relative to their facing.
func _rotate_to_orientation(vec: Vector2i) -> Vector2i:
	var v = Vector2(vec)
	v = v.rotated(deg_to_rad(orientation)).round()
	# As we only rotate by 90, 180 or 270 degrees, integer inputs will always have integer outputs.
	# Thus, this case loses no information.
	return Vector2i(v)

func highlight_board_cells(actions: Array[BoardPlayable.GameAction]):
	for action in actions:
		if action == null:
			continue
		var target_cell = board.get_cell(action.target)
		target_cell.contained_action = action

func update_color():
	node_sprite.material.set_shader_parameter("shade1", ColorControllers.player_primary_colors[owned_by])
	node_sprite.material.set_shader_parameter("shade2", ColorControllers.player_secondary_colors[owned_by])

func is_paralyzed() -> bool:
	if in_cell == null:
		return false
	# Yes, it's bad form to hardcode a behaviour for a piece in here.
	# But I'm well past my deadline!
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x == 0 and y == 0:
				continue
			var c = board.get_cell(coordinates + Vector2i(x, y))
			if c == null or c.occupying_piece == null:
				continue
			if c.occupying_piece.piece_type != ChessPiece.ePieces.Beast:
				continue
			if friendly_to(c.occupying_piece):
				continue
			return true
	return false
	
func friendly_to(piece: ChessPiece) -> bool:
	return owned_by_player.friendly.has(piece.owned_by)

# Gets a nicely serializable description of possible moves/attacks a piece can do
func _get_actions() -> Array[BoardPlayable.GameAction]:
	assert(false, "_get_actions not overridden in " + get_class())
	return []
	
# Whether a cell passes the basic requirements for movement.
func _can_move(target_position: Vector2i) -> bool:
	if is_paralyzed():
		return false
	var target_cell: BoardCell = board.get_cell(target_position)
	return target_cell != null and target_cell.unobstructed
	
# Whether a cell passes the basic requirements for attacking.
func _can_attack(target_position: Vector2i) -> bool:
	if is_paralyzed():
		return false
	var target_cell: BoardCell = board.get_cell(target_position)
	return target_cell != null\
		and target_cell.occupying_piece != null\
		and target_cell.occupying_piece.piece_type != ChessPiece.ePieces.Blocker\
		and not friendly_to(target_cell.occupying_piece)

# Try to move in a line, or attack what blocks that line.
func _act_in_line(direction: Vector2i, max_distance: int = 50) -> Array[BoardPlayable.GameAction]:
	var actions: Array[BoardPlayable.GameAction] = []
	var dist: int = 1
	while dist <= max_distance:  # Arbitrary cap to prevent infinite loop
		var target_cell = board.get_cell(coordinates + _rotate_to_orientation(direction * dist))
		# Off the board.
		if target_cell == null:
			break

		# Will be replaced with a modifier check in the future.
		if target_cell.occupying_piece != null:
			actions.append(_act_on_cell(target_cell.cell_coordinates))
			break
		# Can happen if we loop around.
		if target_cell.occupying_piece == self:
			break
			
		actions.append(_act_on_cell(target_cell.cell_coordinates))
		
		dist += 1
	return actions

# A standard move or attack to a cell.
func _act_on_cell(cell: Vector2i) -> BoardPlayable.GameAction:
	if board.game_settings.no_retreat:
		var to_cell = _rotate_to_orientation(cell - coordinates)
		if to_cell.y < 0:
			return null
	
	if _can_attack(cell):
		return BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.AttackMove, coordinates, cell)
	elif _can_move(cell):
		return BoardPlayable.GameAction.new(owned_by, BoardPlayable.eActionType.Move, coordinates, cell)
	return null
		
func _on_killed(killer: ChessPiece, victim: ChessPiece):
	Helpers.destroy_node(self)
	in_cell.occupying_piece = null

func _on_kill(killer: ChessPiece, victim: ChessPiece):
	if GameController.game_settings.divine_wind:
		_on_killed(self, self)
	
func serialize() -> BoardBase.PieceState:
	var ps = BoardBase.PieceState.new(
		piece_type,
		coordinates,
		orientation,
		owned_by,
	)
	return ps
