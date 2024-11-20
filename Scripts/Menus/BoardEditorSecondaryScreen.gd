class_name BoardEditorSecondaryScreen
extends Control

@onready
var node_piece_position: Control = $Piece	
@onready
var node_description: RichTextLabel = $Description
@onready
var node_team: Label = $VBoxContainer/Team
@onready
var node_orientation: Label = $VBoxContainer/Team

func _ready():
	node_description.bbcode_enabled = true

func change_piece(_piece_prefab: String):
	for n in node_piece_position.get_children():
		n.queue_free()
	
	var _piece: ChessPiece = PrefabController.get_prefab(_piece_prefab).instantiate()
	node_piece_position.add_child(_piece)
	node_description.text = _piece.piece_description
