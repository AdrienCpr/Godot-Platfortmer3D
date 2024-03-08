extends Control

@onready var button_quit = $VBoxContainer/ButtonQuit

signal cancel_pause()
signal home_pause()

var save:SaveManager = SaveManager.new()

func _on_button_quit_pressed():
	save.save_game()
	get_tree().quit()


func _on_continue_pressed():
	cancel_pause.emit()


func _on_go_home_pressed():
	home_pause.emit()
