extends Control
# graph_node.gd

signal node_clicked(node)

	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("node_clicked", self)
		#print("node clicked")


