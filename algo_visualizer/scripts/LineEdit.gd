extends LineEdit


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	set("theme_override_colors/font_placeholder_color",Color("#a577f4"))

func _on_text_submitted(new_text):
	clear()
