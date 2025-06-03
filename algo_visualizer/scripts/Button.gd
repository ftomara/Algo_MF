extends Button

@onready var popup_panel = $"../PopupPanel"

# Called when the node enters the scene tree for the first time.
func _ready():
	popup_panel.grab_focus() 
	

func _on_pressed():
	$"../AudioStreamPlayer".play()
	popup_panel.popup_centered()


func _on_popup_panel_close_requested():
	popup_panel.hide()

func text_rect(i):
	if i == 0 :
		popup_panel.get_node("bubble").visible = true
	if i == 1:
		popup_panel.get_node("insertion").visible = true
	if i == 2:
		popup_panel.get_node("selection").visible = true
		
		
func reset() :
	popup_panel.get_node("bubble").visible = false
	popup_panel.get_node("insertion").visible = false
	popup_panel.get_node("selection").visible = false	
