extends Node3D

@onready var animation_player:AnimationPlayer = $Bouncer/AnimationPlayer
var jump_force: float = 1000.0
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("Bouncer_Idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		animation_player.play("Bouncer_Bounce")
		$AudioStreamPlayer3D.play()
		GameState.player.velocity.y = 15


func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		animation_player.play("Bouncer_Idle")
