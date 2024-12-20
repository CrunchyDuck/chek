class_name BoardEditorSecondaryScreen
extends Control

@onready
var screen_controller: RightScreenController = $"/root/MainScene/ViewportRightScreen/RightScreenController"

@onready
var node_piece_position: Control = $Piece	
var piece: ChessPiece
@onready
var node_description: RichTextLabel = $Description
@onready
var node_commander: Label = $VBoxContainer/Commander/Value
@onready
var node_orientation: Label = $VBoxContainer/Orientation/Value
@onready
var node_x: Label = $BoardSize/X/Value
@onready
var node_y: Label = $BoardSize/Y/Value

var editor: BoardEditable
var orientation: ChessPiece.Orientation = ChessPiece.Orientation.North
var player: int = 0

var x: int:
	get:
		return GameController.board_state.size.x
var y: int:
	get:
		return GameController.board_state.size.y

const orientation_string = {
	ChessPiece.Orientation.North: "UP",
	ChessPiece.Orientation.East: "RIGHT",
	ChessPiece.Orientation.South: "DOWN",
	ChessPiece.Orientation.West: "LEFT",
}

const player_orientation_default = {
	0: ChessPiece.Orientation.North,
	1: ChessPiece.Orientation.South,
	2: ChessPiece.Orientation.East,
	3: ChessPiece.Orientation.West,
}

#region Events
func _ready():
	node_description.bbcode_enabled = true
	connect_buttons()
	set_button_powers()
	
	GameController.on_game_settings_changed.connect(game_settings_changed)

func _process(delta: float) -> void:
	if GameController.board_state:
		node_x.text = str(x)
		node_y.text = str(y)

func _exit_tree() -> void:
	disconnect_buttons()
	depower_buttons()

func game_settings_changed(new_settings: GameSettings):
	set_button_powers()

func on_enable():
	connect_buttons()
	set_button_powers()

func on_disable():
	disconnect_buttons()
	depower_buttons()
#endregion

# TODO: Light up buttons when available
#region Button events
func prev_x():
	if not multiplayer.is_server() and not GameController.game_settings.can_players_edit:
		return
	var _x = x - 1
	if _x < 1:
		return
	editor.set_board_size(Vector2i(_x, y))
	editor.do_synchronize()
	node_x.text = str(x)
	
func next_x():
	if not multiplayer.is_server() and not GameController.game_settings.can_players_edit:
		return
	var _x = x + 1
	editor.set_board_size(Vector2i(_x, y))
	editor.do_synchronize()
	node_x.text = str(x)
	
func prev_y():
	if not multiplayer.is_server() and not GameController.game_settings.can_players_edit:
		return
	var _y = y - 1
	if _y < 1:
		return
	editor.set_board_size(Vector2i(x, _y))
	editor.do_synchronize()
	node_y.text = str(y)
	
func next_y():
	if not multiplayer.is_server() and not GameController.game_settings.can_players_edit:
		return
	var _y = y + 1
	editor.set_board_size(Vector2i(x, _y))
	editor.do_synchronize()
	node_y.text = str(y)
	
func prev_piece():
	var i = int(piece.piece_type) - 1
	if i < 0:
		i = ChessPiece.ePieces.size() - 1
	var new_piece = ChessPiece.piece_prefabs[i as ChessPiece.ePieces]
	set_piece(new_piece)
	
func next_piece():
	var i = int(piece.piece_type) + 1
	if i >= ChessPiece.ePieces.size():
		i = 0
	var new_piece = ChessPiece.piece_prefabs[i as ChessPiece.ePieces]
	set_piece(new_piece)
	
func prev_player():
	var i = player - 1
	if i < 0:
		i = 3
	set_player(i)
	
func next_player():
	var i = player + 1
	if i >= 4:
		i = 0
	set_player(i)
	
func prev_orientation():
	var i = int(orientation) - 90
	if i < 0:
		i = 270
	set_orientation(i as ChessPiece.Orientation)
	
func next_orientation():
	var i = int(orientation) + 90
	if i >= 360:
		i = 0
	set_orientation(i as ChessPiece.Orientation)
#endregion

func set_piece(_piece_prefab: String):
	for n in node_piece_position.get_children():
		Helpers.destroy_node(n)
	
	piece = PrefabController.get_prefab(_piece_prefab).instantiate()
	node_piece_position.add_child(piece)
	node_description.text = piece.piece_description
	piece.orientation = orientation
	piece.owned_by = player
	editor.paint_piece = piece.serialize()

func set_orientation(_orientation: ChessPiece.Orientation):
	orientation = _orientation
	piece.orientation = orientation
	node_orientation.text = orientation_string[orientation]
	editor.paint_piece = piece.serialize()
	
func set_player(_player: int):
	player = _player
	piece.owned_by = player
	node_commander.text = str(player)
	editor.paint_piece = piece.serialize()
	set_orientation(player_orientation_default[_player])

func set_button_powers():
	for p in screen_controller.left_button_power:
		p.set_self(true)
	for p in screen_controller.right_button_power:
		p.set_self(true)
		
	if multiplayer.is_server():
		return
		
	var can_edit_board = GameController.game_settings.can_players_edit
	screen_controller.left_button_power[0].set_self(can_edit_board)
	screen_controller.left_button_power[1].set_self(can_edit_board)
	screen_controller.right_button_power[0].set_self(can_edit_board)
	screen_controller.right_button_power[1].set_self(can_edit_board)

func depower_buttons():
	for p in screen_controller.left_button_power:
		p.set_self(false)
	for p in screen_controller.right_button_power:
		p.set_self(false)

func connect_buttons():
	if screen_controller.left_button[0].on_pressed.is_connected(prev_x):
		return
		
	screen_controller.left_button[0].on_pressed.connect(prev_x)
	screen_controller.right_button[0].on_pressed.connect(next_x)
	
	screen_controller.left_button[1].on_pressed.connect(prev_y)
	screen_controller.right_button[1].on_pressed.connect(next_y)
	
	screen_controller.left_button[2].on_pressed.connect(prev_piece)
	screen_controller.right_button[2].on_pressed.connect(next_piece)
	
	screen_controller.left_button[3].on_pressed.connect(prev_player)
	screen_controller.right_button[3].on_pressed.connect(next_player)
	
	screen_controller.left_button[4].on_pressed.connect(prev_orientation)
	screen_controller.right_button[4].on_pressed.connect(next_orientation)

func disconnect_buttons():
	if not screen_controller.left_button[0].on_pressed.is_connected(prev_x):
		return
		
	screen_controller.left_button[0].on_pressed.disconnect(prev_x)
	screen_controller.right_button[0].on_pressed.disconnect(next_x)
	
	screen_controller.left_button[1].on_pressed.disconnect(prev_y)
	screen_controller.right_button[1].on_pressed.disconnect(next_y)
	
	screen_controller.left_button[2].on_pressed.disconnect(prev_piece)
	screen_controller.right_button[2].on_pressed.disconnect(next_piece)
	
	screen_controller.left_button[3].on_pressed.disconnect(prev_player)
	screen_controller.right_button[3].on_pressed.disconnect(next_player)
	
	screen_controller.left_button[4].on_pressed.disconnect(prev_orientation)
	screen_controller.right_button[4].on_pressed.disconnect(next_orientation)
