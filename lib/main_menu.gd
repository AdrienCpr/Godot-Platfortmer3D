class_name MainMenu extends Node3D

#BUTTONS MENU
func _on_menu_button_start_pressed():
	GameState.is_loading_game = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_button_quit_pressed():
	get_tree().quit()

func _on_menu_button_new_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
