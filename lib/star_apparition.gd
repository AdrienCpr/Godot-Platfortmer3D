extends Node3D

@onready var star = $Star
@onready var text = $Text
# Called when the node enters the scene tree for the first time.
func _ready():
	star.hide()
	star.can_be_pick = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.coins == 50 :
		text.hide()
		star.show()
		star.can_be_pick = true
