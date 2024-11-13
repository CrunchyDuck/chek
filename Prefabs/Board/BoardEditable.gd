class_name BoardEditable
extends BoardBase

var GameSetup.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
			deselect_cell()
		else:
			_on_click(event)
			
func _on_click(_event: InputEventMouseButton):
	var new_cell = position_to_cell(get_global_mouse_position())
	if new_cell != null:
		click_on_cell(new_cell)
	else:
		deselect_cell()

func click_on_cell(new_cell: BoardCell):
	if new_cell == null or new_cell.selected:
		deselect_cell()
	elif new_cell.contained_action != null:
		GameController.try_perform_action.rpc_id(1, new_cell.contained_action.serialize())
		deselect_cell()
	else:
		select_cell(new_cell)
