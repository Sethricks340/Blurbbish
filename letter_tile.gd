extends Button

signal tile_released(tile)

var dragging = false
var drag_offset = Vector2()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			drag_offset = get_global_mouse_position() - global_position
			
			if dragging:
				move_to_front()
			else:
				tile_released.emit(self)

	if event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset
		
	#print(global_position)
