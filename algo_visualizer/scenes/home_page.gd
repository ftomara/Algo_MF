extends Control


func _on_array_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_graph_pressed():
	get_tree().change_scene_to_file("res://scenes/graph_scene_.tscn")
