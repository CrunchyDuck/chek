class_name BoardEditorSecondaryScreen
extends Control

@onready
var node_piece_position: Control = $Piece	
var piece: ChessPiece
@onready
var node_description: RichTextLabel = $Description
@onready
var node_team: Label = $VBoxContainer/Team
@onready
var node_orientation: Label = $VBoxContainer/Team

var editor: BoardEditable
var orientation: ChessPiece.Orientation = ChessPiece.Orientation.North
var player: int = 0

const orientation_string = {
	ChessPiece.Orientation.North: "UP",
	ChessPiece.Orientation.East: "RIGHT",
	ChessPiece.Orientation.South: "DOWN",
	ChessPiece.Orientation.West: "LEFT",
}

const player_string = {
	0: "COMMANDER 0",
	1: "COMMANDER 1",
	2: "COMMANDER 2",
	3: "COMMANDER 3",
}

func _ready():
	node_description.bbcode_enabled = true

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
	node_team.text = player_string[player]
	editor.paint_piece = piece.serialize()
