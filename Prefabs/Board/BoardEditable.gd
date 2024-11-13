class_name BoardEditable
extends BoardBase

var paint_piece: GameController.PieceState

func _input(event: InputEvent):
  if event.is_action_pressed("LMB"):
    print("LMB down")
  elif event.is_action_pressed("RMB"):
    print("RMB down")

func spawn_piece(piece_type: GameController.ePieces, coordinate: Vector2i, orientation: ChessPiece.Orientation, owned_by: int) -> ChessPiece:
  var piece: ChessPiece = PrefabController.get_prefab(GameController.piece_prefabs[piece_type]).instantiate()
  var cell = get_cell(coordinate)
  cell.occupying_piece = piece
  piece.Init(coordinate, orientation, owned_by, self)
  node_pieces.add_child(piece)
  piece.position = cell_to_position(coordinate)
  #var p = players_by_game_id[owned_by]
  #p.pieces.append(piece)
  return piece

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
