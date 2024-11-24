class_name BoardEditorSecondaryScreen
extends Control

@onready
var screen_controller: SecondaryScreenController = $"/root/MainScene/ViewportRightScreen/SecondaryScreenController"

@onready
var node_piece_position: Control = $Piece	
var piece: ChessPiece
@onready
var node_description: RichTextLabel = $Description
@onready
var node_commander: Label = $VBoxContainer/Commander/Value
@onready
var node_orientation: Label = $VBoxContainer/Orientation/Value

var editor: BoardEditable
var orientation: ChessPiece.Orientation = ChessPiece.Orientation.North
var player: int = 0

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

func _ready():
	node_description.bbcode_enabled = true
	screen_controller.left_button[2].on_pressed.connect(prev_piece)
	screen_controller.right_button[2].on_pressed.connect(next_piece)
	
	screen_controller.left_button[3].on_pressed.connect(prev_player)
	screen_controller.right_button[3].on_pressed.connect(next_player)
	
	screen_controller.left_button[4].on_pressed.connect(prev_orientation)
	screen_controller.right_button[4].on_pressed.connect(next_orientation)

#region Button events
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
		n.queue_free()
	
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
