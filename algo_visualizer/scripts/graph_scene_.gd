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
@onready var queue_container = $StackPanel2/VBoxContainer
@onready var stack_container = $StackPanel/ScrollContainer/VBoxContainer
@onready var node_value_window = $NodeValueWindow
@onready var line_edit = $NodeValueWindow/LineEdit
@onready var speed_menu = $SpeedMenu
@onready var menu_options = $MenuOptions
@onready var guide_window = $guideWindow
@onready var line_layer = $LinesLayer
#@onready var delete_node_dialog = $DeleteNodeDialog
#stack_container.custom_constants.separation = 20

func _ready():
	print("Ready!")
	node_value_window.visible = false
	

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Clicked at:", event.position)
		spawn_graph_node(event.position)
		
		

func spawn_graph_node(node_position: Vector2):
	var node = GraphNodeScene.instantiate()
	node.position = node_position
	node.connect("node_clicked",Callable(self, "_on_node_clicked"))
	add_child(node)
	# Open value window
	current_edit_node = node
	node_value_window.visible = true
	line_edit.clear()
	line_edit.grab_focus()

func create_queue():
	$StackPanel2/Label.visible =true
	for i in range(nodes.size()):
		var text = nodes[i].get_node("Gnode/Label").text
		spawn_square_in_queue(text)

func spawn_square_in_queue(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	queue_container.add_child(square_instance)
	

func create_stack():
	$StackPanel/Label.visible = true
	for i in range(nodes.size()):
		var reversed_index = nodes.size() - 1 - i
		var text = nodes[reversed_index].get_node("Gnode/Label").text
		spawn_stack_item(text)


func spawn_stack_item(text: String):
	var square_instance = square.instantiate()
	square_instance.get_node("Gnode/Label").text = text
	stack_container.add_child(square_instance)
	
func _on_line_edit_text_submitted(new_text):
	if current_edit_node:
		current_edit_node.get_node("Gnode/Label").text = new_text
		nodes.push_back(current_edit_node)
		print("Node label set to:", new_text)
	_hide_value_window()

func _on_node_clicked(node):
	if click_number < 2:
		click_number+=1
		if node_a == null:
			node_a = node
		elif node_b == null:
			node_b = node			
	if click_number == 2 && node_a && node_b && node_a!=node_b:
		_draw_line(node_a,node_b)
		click_number = 0
		node_a = null
		node_b = null
	#elif click_number == 2 && node_a && node_b && node_a==node_b:
	#	delet_node_dialog.show()
	#	delet_node_dialog.grab_focus()
	
	
		
func _delete_node(nodea):
	nodes.erase(nodea)
	connections.erase(nodea)
	for n in connections.keys():
		if node_a in connections[n]:
			connections[n].erase(nodea)
	var node_position = nodea.position+Vector2(37,37)
	for line in lines:
		for point in line.points:
			if point == node_position:
				lines.erase(line)
				line_layer.remove_child(line)
	remove_child(nodea)

func _draw_line(nodea,nodeb):
	var line = Line2D.new()
	if not connections.has(nodea):
		connections[nodea]=[]
	if not connections[nodea].has(nodeb):
		connections[nodea].append(nodeb)
	
	if not connections.has(nodeb):
		connections[nodeb]=[]
	if not connections[nodeb].has(nodea):
		connections[nodeb].append(nodea) 
		
	line.add_point(nodea.position+Vector2(37,37))
	line.add_point(nodeb.position+Vector2(37,37))
	lines.append(line)
	line_layer.add_child(line)
	
	print(connections)
	
	
func _on_button_pressed():
	_hide_value_window()

func _hide_value_window():
	node_value_window.visible = false
	current_edit_node = null
	line_edit.clear()
	
func _on_speed_pressed():
	speed_menu.visible = !speed_menu.visible

func _on_algo_icon_pressed():
	menu_options.visible = !menu_options.visible


func _on_user_guide_pressed():
	guide_window.visible = !guide_window.visible


func _on_delete_pressed():
	_delete_node(node_a)
	click_number = 0
	node_a = null
	node_b = null
#	delet_node_dialog.hide()


func _on_cancel_pressed():
	print("cancel pressed")
#	delet_node_dialog.hide()
	#delet_node_dialog.visible=false


func _on_dfs_pressed():
	create_stack()
	create_queue()
