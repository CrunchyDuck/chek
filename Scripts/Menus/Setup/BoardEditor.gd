extends Control

var board: BoardEditable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  # Spawn a board
  board = PrefabController.spawn_prefab("Board.BoardEditable", str(get_path()) + "/Board")
  board.load_state(GameController.board_state)
  
  # Set side screen to have information panel
