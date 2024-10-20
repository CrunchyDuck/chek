class_name BoardCell
extends Node2D

# References
@onready var sprite: Sprite2D = $Sprite2D

var board: Board = null
var cell_coordinates: Vector2i
var _occupying_piece: ChessPiece = null
# I don't like how much is implicitly done here.
# If this proves to cause issues, I should go through signals instead, like on_kill
var occupying_piece: ChessPiece

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
var contained_action: Board.GameAction:
	get:
		return _contained_action
	set(value):
		_contained_action = value
		_update_color()

var _selected = false
var _blocked: bool = false
var _contained_action: Board.GameAction = null
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
			Board.eActionType.Move:
				color = color_move
			Board.eActionType.Attack, Board.eActionType.AttackMove:
				color = color_attack
			_:
				assert(false, "Unhandled eActionType in BoardCell " + str(cell_coordinates))
	else:
		color = color_black
		if (cell_coordinates.x + cell_coordinates.y) % 2 == 0:
			color = color_white

	sprite.self_modulate = color
