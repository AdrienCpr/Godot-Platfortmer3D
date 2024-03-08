class_name Chest extends Node3D

@onready var animation_player:AnimationPlayer = $Chest/AnimationPlayer
var is_open:bool = false
 
func _ready():
	animation_player.play("Chest_Close")
