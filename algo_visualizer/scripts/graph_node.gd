extends Control
class_name GraphNodePiece
# graph_node.gd

enum E_NODE_STATE {normal, selected, deleting}
var current_state : E_NODE_STATE = E_NODE_STATE.normal
signal node_clicked(node)

	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("node clicked")
		emit_signal("node_clicked", self)

func update_state(p_state: E_NODE_STATE):
	current_state = p_state
	match current_state:
		E_NODE_STATE.normal:
			modulate = Color.WHITE
		E_NODE_STATE.selected:
			modulate = Color.YELLOW
		E_NODE_STATE.deleting:
			modulate = Color.RED
