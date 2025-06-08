extends Control

const VERTICAL_SPACING := 60
const HORIZONTAL_SPACING := 60

var visited := {}  # Tracks visited nodes
var stack := []    # Stack used for backtracking
var queue := []    

enum Modes {DeleteMode , LineMode , NormalMode}
var Current_mode = Modes.NormalMode
var GraphNodeScene = preload("res://scenes/graph_node.tscn")
var square = preload("res://scenes/square.tscn")

var first_selected = null
var current_edit_node: GraphNodePiece = null
var click_number = 0
var nodes = []
var node_a : GraphNodePiece = null
var node_b : GraphNodePiece = null
var lines = []
var connections = {}
var is_processing_click = false
var selection_lock = false  # Prevent overlapping selections

@onready var queue_container = $StackPanel2/VBoxContainer
@onready var stack_container = $testing/ScrollContainer/VBoxContainer
@onready var node_value_window = $NodeValueWindow
@onready var line_edit = $NodeValueWindow/LineEdit
@onready var speed_menu = $SpeedMenu
@onready var menu_options = $MenuOptions
@onready var guide_window = $guideWindow
@onready var line_layer = $LinesLayer
@onready var delete_node_dialog = $DeleteNodeDialog
@onready var trash = $trash
@onready var line = $line

func _ready():
	print("Ready!")
	node_value_window.visible = false
	
	if delete_node_dialog:
		delete_node_dialog.visible = false
	
	# Manual signal connections for algorithm buttons
	var dfs_btn = menu_options.get_node("DFS")
	var bfs_btn = menu_options.get_node("BFS")
	
	#if dfs_btn:
		#dfs_btn.pressed.connect(_on_dfs_pressed)
	#if bfs_btn:
		#bfs_btn.pressed.connect(_on_bfs_pressed)

func _input(event):
	if node_value_window.visible or delete_node_dialog.visible or speed_menu.visible or menu_options.visible or guide_window.visible:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Clicked at:", event.position)
		spawn_graph_node(get_global_mouse_position())

func spawn_graph_node(node_position: Vector2):
	print(node_position)
	var node = GraphNodeScene.instantiate()
	node.position = node_position
	# Remove CONNECT_DEFERRED to prevent race conditions
	node.connect("node_clicked", _on_node_clicked)
	add_child(node)
	
	current_edit_node = node
	node_value_window.visible = true
	line_edit.clear()
	line_edit.grab_focus()

func BFS():
	if nodes.is_empty():
		print("No nodes in the graph.")
		return
	var start_node = nodes.front()
	visited.clear()
	queue.clear()
	await _bfs_visit(start_node)

func _bfs_visit(node: GraphNodePiece):
	queue.append(node)
	visited[node]=true
	await Add_to_queue(node)
	await get_tree().create_timer(0.3).timeout
	while(not queue.is_empty()):
		var visited_node = queue.front()
		printt(visited_node.get_node("Gnode/Label").text)
		visited_node.update_state(GraphNodePiece.E_NODE_STATE.visited)
		await get_tree().create_timer(0.5).timeout
		queue.pop_front()
		await Remove_from_queue()
		await get_tree().create_timer(0.3).timeout
		for neighbor in connections.get(visited_node,[]):
			if not visited.has(neighbor):
				visited[neighbor]=true
				queue.append(neighbor)
				Add_to_queue(neighbor)
				var l = _get_line_between(visited_node,neighbor)
				if l :
					l.default_color = Color.RED
	

func Add_to_queue(node: GraphNodePiece):
	if node == null:
		print("attempting to add null node to queue")
		return
	var text = node.get_node("Gnode/Label").text
	spawn_square_in_queue(text)
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout

func Remove_from_queue():
	if queue_container.get_child_count()>0:
		queue_container.get_child(0).queue_free()
	await get_tree().process_frame


func DFS():
	if nodes.is_empty():
		print("No nodes in the graph.")
		return
	
	var start_node = nodes[0]  # Optionally make this user-selectable
	visited.clear()
	stack.clear()
	
	await _dfs_visit(start_node)

func _dfs_visit(node: GraphNodePiece) -> void:
	if visited.has(node):
		return
	
	# VISIT NODE
	visited[node] = true
	var text = node.get_node("Gnode/Label").text
	await spawn_square_in_queue(text)
	node.update_state(GraphNodePiece.E_NODE_STATE.visited)
	await Add_to_stack(node)
	await get_tree().create_timer(0.5).timeout  # Delay for visualization
	
	# EXPLORE NEIGHBORS
	for neighbor in connections.get(node, []):
		if not visited.has(neighbor):
			var l = _get_line_between(node, neighbor)
			if l:
				l.default_color = Color.RED  # Highlight current traversal
			await _dfs_visit(neighbor)
			if l:
				l.default_color = Color.GRAY  # Backtracked

	# BACKTRACK (Pop stack)
	await Remove_from_stack()
	await get_tree().create_timer(0.5).timeout

func Add_to_stack(node: GraphNodePiece):
	if node == null:
		push_warning("Attempted to add a null node to the stack.")
		return

	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = node.get_node("Gnode/Label").text
	stack_container.add_child(square_instance)
	
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	if stack_container.get_child_count() > 0:
		$testing/ScrollContainer.ensure_control_visible(stack_container.get_child(stack_container.get_child_count() - 1))


func Remove_from_stack():
	if stack_container.get_child_count() > 0:
		stack_container.get_child(stack_container.get_child_count() - 1).queue_free()
	await get_tree().process_frame

func _get_line_between(node1: GraphNodePiece, node2: GraphNodePiece) -> Line2D:
	var p1 = node1.position + Vector2(37, 37)
	var p2 = node2.position + Vector2(37, 37)
	
	for l in lines:
		if l.points.size() == 2:
			var a = l.points[0]
			var b = l.points[1]
			if (a == p1 and b == p2) or (a == p2 and b == p1):
				return l
	return null


func clear_queue():
	for child in queue_container.get_children():
		child.queue_free()

func spawn_square_in_queue(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	queue_container.add_child(square_instance)

func clear_stack():
	for child in stack_container.get_children():
		child.queue_free()

func spawn_stack_item(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	stack_container.add_child(square_instance)
	await get_tree().process_frame
	if stack_container.get_child_count() > 0:
		$testing/ScrollContainer.ensure_control_visible(stack_container.get_child(stack_container.get_child_count() - 1))

func _on_line_edit_text_submitted(new_text):
	if current_edit_node and new_text != "":
		current_edit_node.get_node("Gnode/Label").text = new_text

		if not nodes.has(current_edit_node):
			nodes.push_back(current_edit_node)

		#if not nodes.has(current_edit_node):  # Prevent duplicates
			#nodes.push_back(current_edit_node)

		print("Node label set to:", new_text)
		print("Total nodes: ", nodes.size())
	_hide_value_window()

func _on_node_clicked(node):
	
	print("\n=== NODE CLICK DEBUG ===")
	print("Clicked node: ", node.get_node("Gnode/Label").text)
	print("Current click_number: ", click_number)
	print("Current node_a: ", node_a.get_node("Gnode/Label").text if node_a else "null")
	print("Current node_b: ", node_b.get_node("Gnode/Label").text if node_b else "null")
	
	if Current_mode == Modes.DeleteMode :
		
		node_a = node
		node_a.update_state(GraphNodePiece.E_NODE_STATE.deleting)
		delete_node_dialog.popup_centered()
		
	if Current_mode == Modes.LineMode:
		
		if click_number == 0:
			node_a = node
			click_number = 1
			print("Set as node_a: ", node_a.get_node("Gnode/Label").text)
			node_a.update_state(GraphNodePiece.E_NODE_STATE.selected)
		elif click_number == 1:
			node_b = node
			click_number = 2
			print("Set as node_b: ", node_b.get_node("Gnode/Label").text)
			node_a.update_state(GraphNodePiece.E_NODE_STATE.selected)
		if click_number == 2 and node_a != null and node_b != null and node_a != node_b:
			print("Different nodes - attempting to create connection")
			_draw_line(node_a, node_b)
			_reset_selection()
		elif click_number == 2 and node_a == node_b:
			_reset_selection()


	
	#print("After processing - click_number: ", click_number)
	#print("After processing - click_number: ", click_number)d
	#print("=== END DEBUG ===\n")
	

func _reset_selection():
	print("Resetting selection")
	click_number = 0
	if node_a:
		node_a.update_state(GraphNodePiece.E_NODE_STATE.normal)
	if node_b:
		node_b.update_state(GraphNodePiece.E_NODE_STATE.normal)
	node_a = null
	node_b = null

func _delete_node(nodea):
	
	if not nodea:
		return
	
	print("Deleting node: ", nodea.get_node("Gnode/Label").text)
	
	# Remove from nodes array
	nodes.erase(nodea)
	
	# Remove from connections
	connections.erase(nodea)
	for n in connections.keys():
		if nodea in connections[n]:
			connections[n].erase(nodea)
	
	# Remove associated lines
	var node_position = nodea.position + Vector2(37, 37)
	var lines_to_remove = []
	
	for l in lines:
		for point in l.points:
			if point == node_position:
				lines_to_remove.append(l)
				break
	
	for l in lines_to_remove:
		lines.erase(l)
		if l.get_parent():
			l.get_parent().remove_child(l)
		l.queue_free()
	
	# Remove the node
	if nodea.get_parent():
		nodea.get_parent().remove_child(nodea)
	nodea.queue_free()

func _draw_line(nodea, nodeb):
	if not nodea or not nodeb:
		print("ERROR: One of the nodes is null")
		return
	
	print("Drawing line between: ", nodea.get_node("Gnode/Label").text, " and ", nodeb.get_node("Gnode/Label").text)
	
	# Check if connection already exists
	if connections.has(nodea) and nodeb in connections[nodea]:
		print("Connection already exists between these nodes!")
		return
	
	var line_vector = Line2D.new()
	line_vector.width = 5.0
	line_vector.default_color = Color.WHITE
	
	# Add bidirectional connection
	if not connections.has(nodea):
		connections[nodea] = []
	connections[nodea].append(nodeb)
	
	if not connections.has(nodeb):
		connections[nodeb] = []
	connections[nodeb].append(nodea)
	
	line_vector.add_point(nodea.position + Vector2(37, 37))
	line_vector.add_point(nodeb.position + Vector2(37, 37))
	lines.append(line_vector)
	line_layer.add_child(line_vector)
	
	print("SUCCESS: Line created between ", nodea.get_node("Gnode/Label").text, " and ", nodeb.get_node("Gnode/Label").text)
	print("Total connections: ", connections.size())

func _on_button_pressed():
	_hide_value_window()

func _hide_value_window():
	node_value_window.visible = false
	current_edit_node = null
	line_edit.clear()

func _on_speed_pressed():
	menu_options.visible = false
	guide_window.visible = false
	speed_menu.visible = !speed_menu.visible

func _on_algo_icon_pressed():
	speed_menu.visible = false
	guide_window.visible = false
	menu_options.visible = !menu_options.visible

func _on_user_guide_pressed():
	speed_menu.visible = false
	menu_options.visible = false
	guide_window.visible = !guide_window.visible

func _on_dfs_pressed():
	print("DFS pressed")
	menu_options.visible = false
	clear_queue()
	DFS()
 
	# Add small delay to prevent interference
	#await get_tree().process_frame


	#create_stack()

func _on_bfs_pressed():
	print("BFS pressed")
	menu_options.visible = false
	#clear_queue()
	BFS()

	#await get_tree().process_frame

	#create_queue()

func _on_delete_node_dialog_confirmed():
	print("Delete confirmed")
	_delete_node(node_a)
	_reset_selection()
	delete_node_dialog.hide()

func _on_delete_node_dialog_canceled():
	print("Delete canceled")
	_reset_selection()
	delete_node_dialog.hide()


func _on_trash_toggled(toggled_on):
	print("======== Trash TOGGLED==========")
	if !toggled_on and Current_mode == Modes.DeleteMode :
		Current_mode = Modes.NormalMode
		print(" Trash toggle off")
	
	elif toggled_on and Current_mode == Modes.LineMode or Current_mode == Modes.NormalMode:
		Current_mode= Modes.DeleteMode	
		print(" Trash toggle on")		


func _on_line_toggled(toggled_on):
	print("======== Line TOGGLED==========")
	if !toggled_on and Current_mode == Modes.LineMode :
		Current_mode = Modes.NormalMode
		print(" Line toggle off")
	
	elif toggled_on and Current_mode == Modes.DeleteMode or Current_mode == Modes.NormalMode:
		Current_mode= Modes.LineMode	
		print(" Line toggle on")		
