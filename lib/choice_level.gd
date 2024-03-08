class_name Level extends Node3D

@export var key:String

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		GameState.player_health = 0
