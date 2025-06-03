extends Control

var GraphNodeScene = preload("res://scenes/graph_node.tscn")
var first_selected = null
var current_edit_node: Control = null

@onready var node_value_window = $NodeValueWindow
@onready var line_edit = $NodeValueWindow/LineEdit
@onready var speed_menu = $SpeedMenu
@onready var menu_options = $MenuOptions

func _ready():
	print("Ready!")
	node_value_window.visible = false

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		print("Clicked at:", event.position)
		spawn_graph_node(event.position)

func spawn_graph_node(position: Vector2):
	var node = GraphNodeScene.instantiate()
	node.position = position
	add_child(node)


	# Open value window
	current_edit_node = node
	node_value_window.visible = true
	line_edit.clear()
	line_edit.grab_focus()


func _on_line_edit_text_submitted(new_text):
	if current_edit_node:
		current_edit_node.get_node("Gnode/Label").text = new_text
		print("Node label set to:", new_text)
	_hide_value_window()

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
