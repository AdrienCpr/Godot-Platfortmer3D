class_name Main extends Node3D

@onready var ui_level = $UiLevel
@onready var enter_level_ui:VBoxContainer = $UiLevel/EnterLevelUI
@onready var image_star_end:TextureRect = $UiLevel/EnterLevelUI/HBoxContainer/StarEndLevelImg
@onready var image_star_coin:TextureRect = $UiLevel/EnterLevelUI/HBoxContainer/Star100CoinsImg
@onready var image_star_coin_empty:TextureRect = $UiLevel/EnterLevelUI/HBoxContainer/Star100CoinsImgEmpty
@onready var image_star_end_empty:TextureRect = $UiLevel/EnterLevelUI/HBoxContainer/StarEndLevelImgEmpty
@onready var label_interact:Label = $UiLevel/Interact
@onready var pause = $Pause
@onready var button_continue:Button = $Pause/VBoxContainer/Continue

var current_level_change = null
var save:SaveManager = SaveManager.new()
var chest:Chest = null

# Called when the node enters the scene tree for the first time.
func _ready():
	enter_level_ui.visible = false
	label_interact.visible = false
	pause.visible = false
	GameState.player = $Player
	if GameState.is_loading_game :
		save.load_game()
	_enter_level("default", GameState.current_level_key, true)

func _enter_level(from:String, to:String, use_spawn_point:bool = true):
	if (GameState.current_level != null):
		GameState.current_level.call_deferred('queue_free')
	GameState.current_level = load("res://levels/" + to + ".tscn").instantiate()
	GameState.current_level_key = to
	add_child(GameState.current_level)
	GameState.current_level.process_mode = PROCESS_MODE_PAUSABLE
	if (use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if (spawnpoint.key == from):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation

func _input(event):
	if (not get_tree().paused):
		if Input.is_action_just_pressed("player_interact"):
			if (chest != null) :
				$Chest.play()
				GameState.has_key = false
				GameState.coins += 10
				chest.animation_player.play("Chest_Open")
				chest.is_open = true
				chest = null
			if (current_level_change != null) :
				_enter_level(GameState.current_level_key, current_level_change.destination)
	if Input.is_action_just_released("pause"):
		_pause()
	
func _pause():
	ui_level.visible = not ui_level.visible
	pause.visible = not pause.visible
	if get_tree().paused:
		button_continue.grab_focus()
		#GameState.player.capture_mouse()
	else:
		#GameState.player.release_mouse()
		button_continue.grab_focus()
	get_tree().paused = not get_tree().paused

func _on_player_iteraction_detected(node):
	var object = node.get_parent()
	
	if (object is Star):
		_interact_star(object)
		
	if (object is Trap):
		_interact_trap()

	if (object is LevelChange):
		_interact_level_change(object)
		
	if (object is Chest):
		_interact_chest(object)
		
	if (object is Coin) :
		$Coin.play()
		GameState.coins += 1
		object.queue_free()
		
	if (object is Heart):
		$Heart.play()
		GameState.player_health += 1
		object.queue_free()
		
	if (object is Key):
		$Key.play()
		GameState.has_key = true
		object.queue_free()


func _on_player_iteraction_detected_end(node):
	current_level_change = null
	label_interact.visible = false
	enter_level_ui.visible = false

func _on_eject_timer_timeout():
	GameState.player_health_change = false
	
func _interact_star(star):
	if star.can_be_pick:
		$Star.play()
		GameState.player_health = 3
		GameState.coins = 0
		GameState.Stars[star.level][star.type] = true
		star.queue_free()
		_enter_level(star.level, "choice_level", true)
	
func _interact_trap():
	GameState.player_health_change = true
	$eject_timer.start()
	GameState.player.hit_sound.play()
	GameState.player_health -= 1
	GameState.player.velocity.y = 2
	GameState.player.velocity.z = -5
	
func _interact_level_change(object):
	if object.destination != "choice_level":
		if GameState.Stars[object.destination]["end"] == true :
			image_star_end.visible = true
			image_star_end_empty.visible = false
		else:
			image_star_end.visible = false
			image_star_end_empty.visible = true
		if GameState.Stars[object.destination]["coin"] == true :
			image_star_coin.visible = true
			image_star_coin_empty.visible = false
		else:
			image_star_coin.visible = false
			image_star_coin_empty.visible = true
		enter_level_ui.visible = true
		label_interact.text = tr("Enter Level")
	else:
		enter_level_ui.visible = false
		label_interact.text = tr("Return Home")
	label_interact.visible = true
	current_level_change = object
	
func _interact_chest(object):
	if GameState.has_key :
		label_interact.text = tr("Open Chest")
		label_interact.visible = true
		chest = object
	else:
		if object.is_open == false :
			label_interact.text = tr("You need a key")
			label_interact.visible = true


func _on_pause_cancel_pause():
	_pause()

func _on_pause_home_pause():
	_enter_level("default", "choice_level")
	_reset_inventory()
	_pause()
	
func _reset_inventory():
	GameState.player_health = 3
	GameState.coins = 0
	GameState.has_key = false
