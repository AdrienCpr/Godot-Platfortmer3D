class_name Coin extends Node3D

@onready var coin:Node3D = $"."

func _process(delta):
	coin.rotate_y(deg_to_rad(60) * delta)
