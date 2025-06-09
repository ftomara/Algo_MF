extends Control
class_name GraphNodePiece
# graph_node.gd

enum E_NODE_STATE { normal, selected, visited, deleting }
var current_state : E_NODE_STATE = E_NODE_STATE.normal
signal node_clicked(node)

	
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("node clicked")
		emit_signal("node_clicked", self)

func update_state(state):
	match state:
		E_NODE_STATE.visited:
			$Gnode.modulate = Color.GREEN
		E_NODE_STATE.selected:
			$Gnode.modulate = Color.PLUM
		E_NODE_STATE.normal:
			$Gnode.modulate = Color.WHITE
		E_NODE_STATE.deleting:
			$Gnode.modulate = Color.RED
