class_name BoardEditor
extends Control

var board: BoardEditable
var editor_screen: BoardEditorSecondaryScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Spawn a board
	board = PrefabController.spawn_prefab("Board.BoardEditable", str(get_path()) + "/Board")
	board.load_state(GameController.board_state)
	
	# Set side screen to have information panel
	for n in GameController.screen_secondary.get_children():
		n.queue_free()
	
	editor_screen = PrefabController.get_prefab("SecondaryScreen.BoardEditor").instantiate()
	GameController.screen_secondary.add_child(editor_screen)
	editor_screen.editor = board
	editor_screen.set_piece(ChessPiece.piece_prefabs[ChessPiece.ePieces.Pawn])
	editor_screen.set_player(0)
	
