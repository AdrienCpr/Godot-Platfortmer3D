class_name HazardSpike extends Node3D

@export var start_at_in_sec:float
@export var interval_in_sec:float
@onready var timer_interval:Timer = $TimerInterval
@onready var timer_start:Timer = $TimerStart
@onready var animation_player:AnimationPlayer = $Hazard_SpikeTrap2/AnimationPlayer
var character = null
var can_be_damage = true
# Called when the node enters the scene tree for the first time.

func _ready():
	timer_start.wait_time = start_at_in_sec
	timer_interval.wait_time = interval_in_sec
	timer_start.start()

func _process(delta):
	if character != null :
		if animation_player.is_playing() and can_be_damage:
			GameState.player.hit_sound.play()
			can_be_damage = false
			GameState.player_health -= 1
			GameState.player.velocity.y = 5

func _on_timer_start_timeout():
	_call_spike()

func _call_spike():
	timer_interval.start()
	animation_player.play("SpikeTrap_Activate")

func _on_timer_interval_timeout():
	_call_spike()

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		can_be_damage = true
		character = body

func _on_area_3d_body_exited(body):
	character = null
