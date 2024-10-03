class_name ChessPiece
extends Node2D

var board: Board:
	get:
		if in_cell == null:
			return null
		return in_cell.board
var in_cell: BoardCell
var pos: Vector2i:
	get:
		return in_cell.cell_coordinates
var move_count: int = 0
var owned_by: GameController.Player
var orientation: ChessPiece.Orientation = Orientation.North

signal on_kill(killer, victim)
signal on_killed(killer, victim)

# TODO: Make pieces use different spite based on owner
func Init(cell: BoardCell, orientation: ChessPiece.Orientation, owned_by: GameController.Player) -> void:
	self.in_cell = cell
	self.orientation = orientation
	self.owned_by = owned_by

# This lets us rotate vectors to be from the perspective of its team.
# y = 1 for the top of the board (Black, in a normal game), will be y = -1 relative to their facing.
func _rotate_to_orientation(vec: Vector2i) -> Vector2i:
	var v = Vector2(vec)
	v = v.rotated(deg_to_rad(orientation)).round()
	# As we only rotate by 90, 180 or 270 degrees, integer inputs will always have integer outputs.
	# Thus, this case loses no information.
	return Vector2i(v)

func highlight_board_cells(actions: Array[GameController.GameAction]):
	for action in actions:
		var target_cell = board.get_cell(action.target)
		target_cell.contained_action = action
		
# Gets a nicely serializable description of possible moves/attacks a piece can do
func _get_actions() -> Array[GameController.GameAction]:
	assert(false, "_get_actions not overridden in " + get_class())
	return []
	
# Whether a cell passes the basic requirements for movement.
func _can_move(target_position: Vector2i) -> bool:
	var target_cell: BoardCell = board.get_cell(target_position)
	return target_cell != null and target_cell.unobstructed
	
# Whether a cell passes the basic requirements for attacking.
func _can_attack(target_position: Vector2i) -> bool:
	var target_cell: BoardCell = board.get_cell(target_position)
	return target_cell != null and target_cell.occupying_piece != null and\
			not owned_by.friendly.has(target_cell.occupying_piece.owned_by)

# Try to move in a line, or attack what blocks that line.
func _act_in_line(direction: Vector2i) -> Array[GameController.GameAction]:
	var actions: Array[GameController.GameAction] = []
	var dist: int = 1
	while dist < 50:  # Arbitrary cap to prevent infinite loop
		var target_cell = board.get_cell(pos + _rotate_to_orientation(direction * dist))
		# Off the board.
		if target_cell == null:
			break
		elif _can_attack(target_cell.cell_coordinates):
			actions.append(GameController.GameAction.new(owned_by.id, GameController.eActionType.AttackMove, pos, target_cell.cell_coordinates))
		elif _can_move(target_cell.cell_coordinates):
			actions.append(GameController.GameAction.new(owned_by.id, GameController.eActionType.Move, pos, target_cell.cell_coordinates))
		
		# Will be replaced with a modifier check in the future.
		if target_cell.occupying_piece != null:
			break
		# Can happen if we loop around.
		if target_cell.occupying_piece == self:
			break
		
		dist += 1
		if dist == 50:
			print("Reached iteration cap for piece highlighting")
	return actions

# A standard move or attack to a cell.
func _act_on_cell(cell: Vector2i) -> GameController.GameAction:
	if _can_attack(cell):
		return GameController.GameAction.new(owned_by.id, GameController.eActionType.AttackMove, pos, cell)
	elif _can_move(cell):
		return GameController.GameAction.new(owned_by.id, GameController.eActionType.Move, pos, cell)
	return null
		
enum Orientation {
	# South is the start as y is down in Godot.
	South = 0,
	West = 90,
	North = 180,
	East = 270,
}
