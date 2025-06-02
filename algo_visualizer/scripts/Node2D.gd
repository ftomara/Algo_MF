extends Node2D
# ملهاش لازمة
@onready var drop_menu = $OptionButton

func add_items():
	drop_menu.add_item("Selection Sort")
	drop_menu.add_item("Merge Sort")
	drop_menu.add_item("quick Sort")
	drop_menu.add_item("Insertion Sort")
	


func _on_option_button_item_selected(index):
	var current_selected = index
	
