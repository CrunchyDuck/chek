class_name BoardCell
extends Node2D

var sprite: Sprite2D:
	get:
		return $Sprite2D

var board: BoardBase = null
var _cell_coordinates: Vector2i
var cell_coordinates: Vector2i:
	get:
		return _cell_coordinates
	set(value):
		_cell_coordinates = value
		_update_color()
var _occupying_piece: ChessPiece
var occupying_piece: ChessPiece:
	get:
		return _occupying_piece
	set(value):
		_occupying_piece = value
		_hide_if_blocked()

#region States
var unobstructed: bool:
	get:
		return not blocked and occupying_piece == null
var selected: bool:
	get:
		return _selected
	set(value):
		_selected = value
		_update_color()
var blocked: bool:
	get:
		return _blocked
	set(value):
		_blocked = value
		_update_color()
var contained_action: BoardPlayable.GameAction:
	get:
		return _contained_action
	set(value):
		_contained_action = value
		_update_color()

var _selected = false
var _blocked: bool = false
var _contained_action: BoardPlayable.GameAction = null
#endregion

#region Colours
const color_white: Color = ColorController.colors["primary"]
const color_black: Color = ColorController.colors["secondary"]
const color_move: Color = ColorController.colors["c2"]
const color_attack: Color = ColorController.colors["c5"]
const color_blocked: Color = ColorController.colors["c6"]
const color_selected: Color = ColorController.colors["c3"]
#endregion

func reset_state():
	blocked = false
	selected = false
	contained_action = null
	_update_color()

func _update_color():
	var color: Color
	if selected:
		color = color_selected
	elif blocked:
		color = color_blocked	
	elif contained_action != null:
		match contained_action.type:
			BoardPlayable.eActionType.Move:
				color = color_move
			BoardPlayable.eActionType.Attack, BoardPlayable.eActionType.AttackMove:
				color = color_attack
			_:
				assert(false, "Unhandled eActionType in BoardCell " + str(cell_coordinates))
	else:
		color = color_black
		if (cell_coordinates.x + cell_coordinates.y) % 2 == 0:
			color = color_white

	sprite.self_modulate = color

func _hide_if_blocked():
	sprite.visible = true
	if occupying_piece != null and occupying_piece.piece_type == ChessPiece.ePieces.Blocker:
		sprite.visible = false
