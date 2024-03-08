extends Control

@onready var button_start:Button = $Control/MarginContainer/VBoxContainer/Start
@onready var button_new:Button = $Control/MarginContainer/VBoxContainer/New

signal button_start_pressed()
signal button_new_pressed()
signal button_quit_pressed()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if FileAccess.file_exists("user://mysave"):
		button_start.grab_focus()
	else:
		button_start.disabled = true
		button_new.grab_focus()

func _on_start_pressed():
	GameState.current_level_key = "choice_level"
	button_start_pressed.emit()

func _on_quit_pressed():
	button_quit_pressed.emit()

func _on_new_pressed():
	button_new_pressed.emit()
