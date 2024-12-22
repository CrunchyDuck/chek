class_name BoardEditor
extends Control

var board: BoardEditable
var editor_screen: BoardEditorSecondaryScreen

func _ready() -> void:
	# Spawn a board
	board = PrefabController.spawn_prefab("Board.BoardEditable", str(get_path()) + "/Board")
	board.load_state(GameController.board_state)
	
	GameController.on_board_state_changed.connect(board.load_state)
	visibility_changed.connect(_on_change_visibility)

func _on_change_visibility():
	if not visible:
		Helpers.destroy_node(editor_screen)
	else:
		# Set side screen to have information panel
		for n in GameController.screen_secondary.get_children():
			Helpers.destroy_node(n)
		editor_screen = PrefabController.get_prefab("SecondaryScreen.BoardEditor").instantiate()
		GameController.screen_secondary.add_child(editor_screen)
		editor_screen.editor = board
		editor_screen.set_piece(ChessPiece.piece_prefabs[ChessPiece.ePieces.Pawn])
		editor_screen.set_player(0)

func _exit_tree() -> void:
	Helpers.destroy_node(editor_screen)
