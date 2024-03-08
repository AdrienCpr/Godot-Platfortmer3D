class_name Trap extends Node3D

@onready var trap = $"."
@export var speed:int
@export var direction:String
# Called when the node enters the scene tree for the first time.
func _process(delta):
	if direction == "y":
		trap.rotate_y(deg_to_rad(speed) * delta)
	else :
		trap.rotate_z(deg_to_rad(speed) * delta)
