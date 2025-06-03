extends Control
# graph_node.gd

signal node_clicked(node)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("node_clicked", self)
