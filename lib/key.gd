class_name Key extends Node3D

@onready var key:Node3D = $"."

func _process(delta):
	key.rotate_y(deg_to_rad(60) * delta)
