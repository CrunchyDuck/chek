class_name BoardEditable
extends BoardBase

var paint_piece: BoardBase.PieceState

func _ready():
  paint_piece = BoardBase.PieceState.new(
    BoardBase.ePieces.Pawn,
    Vector2i(0, 0),
    ChessPiece.Orientation.South,
    0
  )

func _input(event: InputEvent):
  var _cell = position_to_cell(get_global_mouse_position())
  if Input.is_action_pressed("LMB"):
    if _cell:
      spawn_piece(paint_piece.type, _cell.cell_coordinates, paint_piece.orientation, paint_piece.player)
  elif Input.is_action_pressed("RMB"):
    if _cell.occupying_piece:
      _cell.occupying_piece.queue_free()
      _cell.occupying_piece = null
  GameController.board_state = serialize()
    
#func _input(event: InputEvent) -> void:
  #if event is InputEventMouseButton and event.is_pressed():
    #if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
      #deselect_cell()
    #else:
      #_on_click(event)
      #
#func _on_click(_event: InputEventMouseButton):
  #var new_cell = position_to_cell(get_global_mouse_position())
  #if new_cell != null:
    #click_on_cell(new_cell)
  #else:
    #deselect_cell()
#
#func click_on_cell(new_cell: BoardCell):
  #if new_cell == null or new_cell.selected:
    #deselect_cell()
  #elif new_cell.contained_action != null:
    #GameController.try_perform_action.rpc_id(1, new_cell.contained_action.serialize())
    #deselect_cell()
  #else:
    #select_cell(new_cell)
