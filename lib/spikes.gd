class_name Spikes extends Node3D
@onready var hit = $Hit

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		hit.play()
		GameState.player_health -= 1
		GameState.player.velocity.y = 3
