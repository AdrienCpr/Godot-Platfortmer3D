class_name Heart extends Node3D

@onready var heart:Node3D = $"."

func _process(delta):
	heart.rotate_y(deg_to_rad(60) * delta)
