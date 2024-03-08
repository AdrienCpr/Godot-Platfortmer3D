extends Control

@onready var heart1 = $MarginContainer/VBoxContainer/HBoxContainer/Heart1
@onready var heart2 = $MarginContainer/VBoxContainer/HBoxContainer/Heart2
@onready var heart3 = $MarginContainer/VBoxContainer/HBoxContainer/Heart3
@onready var label_coin = $MarginContainer/VBoxContainer/HBoxContainer2/Coin
@onready var image_key = $MarginContainer/VBoxContainer/HBoxContainer3/Key

func _process(delta):
	image_key.visible = GameState.has_key
	
	if GameState.player_health == 3 :
		heart1.visible = true
		heart2.visible = true
		heart3.visible = true
	else :
		if GameState.player_health == 2 :
			heart1.visible = true
			heart2.visible = true
			heart3.visible = false
		else:
			if GameState.player_health == 1 :
				heart1.visible = true
				heart2.visible = false
				heart3.visible = false
			else:
				if GameState.player_health == 0 :
					heart1.visible = false
					heart2.visible = false
					heart3.visible = false
		
	label_coin.text = str(GameState.coins)
