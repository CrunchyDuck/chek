extends Control

var board: BoardEditable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
  # Spawn a board
  board = BoardEditable.new()
  board.load_state(GameController.board_state)
  
  # Set side screen to have information panel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
  pass
