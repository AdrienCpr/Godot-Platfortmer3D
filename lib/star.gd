class_name Star extends Node3D

@onready var star = $"."
@export var level:String
@export var type:String
@onready var star_sound:AudioStreamPlayer3D = $Star2

var can_be_pick:bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	star.rotate_y(deg_to_rad(60) * delta)
