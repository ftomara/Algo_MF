extends Control

const VERTICAL_SPACING := 60
const HORIZONTAL_SPACING := 60

var GraphNodeScene = preload("res://scenes/graph_node.tscn")
var square = preload("res://scenes/square.tscn")

var first_selected = null
var current_edit_node: Control = null
var click_number = 0
var nodes = []
var node_a : Control = null
var node_b : Control = null
var lines = []
var connections = {}
var is_processing_click = false  # Prevent multiple clicks

@onready var queue_container = $StackPanel2/VBoxContainer
@onready var stack_container = $testing/ScrollContainer/VBoxContainer
@onready var node_value_window = $NodeValueWindow
@onready var line_edit = $NodeValueWindow/LineEdit
@onready var speed_menu = $SpeedMenu
@onready var menu_options = $MenuOptions
@onready var guide_window = $guideWindow
@onready var line_layer = $LinesLayer
@onready var delete_node_dialog = $DeleteNodeDialog

func _ready():
	print("Ready!")
	node_value_window.visible = false
	# Manual signal connections for delete dialog
	if delete_node_dialog:
		delete_node_dialog.visible = false
	
	# Manual signal connections for algorithm buttons
	var dfs_btn = menu_options.get_node("DFS") # Adjust path as needed
	var bfs_btn = menu_options.get_node("BFS") # Adjust path as needed
	
	if dfs_btn:
		dfs_btn.pressed.connect(_on_dfs_pressed)
	if bfs_btn:
		bfs_btn.pressed.connect(_on_bfs_pressed)
	
func _input(event):
	# Check if any UI element is currently visible to prevent interference
	if node_value_window.visible or delete_node_dialog.visible or speed_menu.visible or menu_options.visible or guide_window.visible:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Clicked at:", event.position)
		spawn_graph_node(event.position)

func spawn_graph_node(node_position: Vector2):
	var node = GraphNodeScene.instantiate()
	node.position = node_position
	# Use call_deferred to prevent signal interference
	node.connect("node_clicked", Callable(self, "_on_node_clicked"), CONNECT_DEFERRED)
	add_child(node)
	
	# Open value window
	current_edit_node = node
	node_value_window.visible = true
	line_edit.clear()
	line_edit.grab_focus()

func create_queue():
	# Clear existing queue items first
	for child in queue_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	$StackPanel2/Label.visible = true
	for i in range(nodes.size()):
		var text = nodes[i].get_node("Gnode/Label").text
		spawn_square_in_queue(text)

func spawn_square_in_queue(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	queue_container.add_child(square_instance)

func create_stack():
	# Clear existing stack items first
	for child in stack_container.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	$StackPanel/Label.visible = true
	for i in range(nodes.size()):
		var reversed_index = nodes.size() - 1 - i
		var text = nodes[reversed_index].get_node("Gnode/Label").text
		await spawn_stack_item(text)  # Wait for each item to be added

func spawn_stack_item(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	stack_container.add_child(square_instance)
	await get_tree().process_frame
	# Ensure the scroll container exists and has children before scrolling
	if stack_container.get_child_count() > 0:
		$testing/ScrollContainer.ensure_control_visible(stack_container.get_child(stack_container.get_child_count() - 1))

func _on_line_edit_text_submitted(new_text):
	if current_edit_node and new_text != "":
		current_edit_node.get_node("Gnode/Label").text = new_text
		#if not nodes.has(current_edit_node):  # Prevent duplicates
			#nodes.push_back(current_edit_node)
		print("Node label set to:", new_text)
	_hide_value_window()

func _on_node_clicked(node):
	# Prevent processing if already handling a click or if dialogs are open
	if is_processing_click or delete_node_dialog.visible:
		return
		
	is_processing_click = true
	
	if click_number < 2:
		click_number += 1
		if node_a == null:
			node_a = node
			print("Selected node A: ", node_a.get_node("Gnode/Label").text)
		elif node_b == null:
			node_b = node
			print("Selected node B: ", node_b.get_node("Gnode/Label").text)
	
	if click_number == 2 and node_a and node_b:
		if node_a != node_b:
			_draw_line(node_a, node_b)
			_reset_selection()
		else:
			# Same node clicked twice - show delete dialog
			delete_node_dialog.popup_centered()
			# Don't reset here, wait for dialog response
	
	# Use timer to prevent rapid clicking
	await get_tree().create_timer(0.1).timeout
	is_processing_click = false

func _reset_selection():
	click_number = 0
	node_a = null
	node_b = null

func _delete_node(nodea):
	if not nodea:
		return
		
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
	
	for line in lines:
		for point in line.points:
			if point == node_position:
				lines_to_remove.append(line)
				break
	
	for line in lines_to_remove:
		lines.erase(line)
		if line.get_parent():
			line.get_parent().remove_child(line)
		line.queue_free()
	
	# Remove the node
	if nodea.get_parent():
		nodea.get_parent().remove_child(nodea)
	nodea.queue_free()

func _draw_line(nodea, nodeb):
	if not nodea or not nodeb:
		return
		
	# Check if connection already exists
	if connections.has(nodea) and nodeb in connections[nodea]:
		print("Connection already exists!")
		return
	
	var line = Line2D.new()
	line.width = 5.0  # Make lines more visible
	line.default_color = Color.WHITE
	
	# Add bidirectional connection
	if not connections.has(nodea):
		connections[nodea] = []
	if not connections[nodea].has(nodeb):
		connections[nodea].append(nodeb)
	
	if not connections.has(nodeb):
		connections[nodeb] = []
	if not connections[nodeb].has(nodea):
		connections[nodeb].append(nodea)
	
	line.add_point(nodea.position + Vector2(37, 37))
	line.add_point(nodeb.position + Vector2(37, 37))
	lines.append(line)
	line_layer.add_child(line)
	
	print("Connection created between: ", nodea.get_node("Gnode/Label").text, " and ", nodeb.get_node("Gnode/Label").text)
	print("Total connections: ", connections)

func _on_button_pressed():
	_hide_value_window()

func _hide_value_window():
	node_value_window.visible = false
	current_edit_node = null
	line_edit.clear()

func _on_speed_pressed():
	# Close other menus first
	menu_options.visible = false
	guide_window.visible = false
	speed_menu.visible = !speed_menu.visible

func _on_algo_icon_pressed():
	# Close other menus first
	speed_menu.visible = false
	guide_window.visible = false
	menu_options.visible = !menu_options.visible

func _on_user_guide_pressed():
	# Close other menus first
	speed_menu.visible = false
	menu_options.visible = false
	guide_window.visible = !guide_window.visible

func _on_dfs_pressed():
	print("DFS pressed")
	# Close menu first
	menu_options.visible = false
	# Add small delay to prevent interference
	#await get_tree().process_frame
	create_stack()

func _on_bfs_pressed():
	print("BFS pressed")
	# Close menu first
	menu_options.visible = false
	# Add small delay to prevent interference
	#await get_tree().process_frame
	create_queue()


func _on_delete_node_dialog_confirmed():
	_delete_node(node_a)
	_reset_selection()
	delete_node_dialog.hide()


func _on_delete_node_dialog_canceled():
	print("Cancel pressed")
	_reset_selection()
	delete_node_dialog.hide()
