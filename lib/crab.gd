class_name Enemy extends CharacterBody3D

#@export var health:int 
#@export var speed:int
@onready var animation_player = $visuals/AnimationPlayer
@onready var raycast = $RayCast3D
@onready var timer = $Timer
@onready var hit_receive:AudioStreamPlayer3D = $HitReceive
@onready var death_sound:AudioStreamPlayer3D = $Death
#var health:int = 20
#var speed:int = 3
#var detection_radius:float = 5
var can_be_damage:bool = true
var is_in_air:bool = false
var is_locked:bool = false
var detection_radius = 10
var health:int = 15
var speed:int = 3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ANIM_IDLE = ""
# Called when the node enters the scene tree for the first time.
func _ready():
	var number = RandomNumberGenerator.new().randi_range(1,5)
	if number == 1 :
		ANIM_IDLE = "Idle"
	else:
		if number == 2 :
			ANIM_IDLE = "Dance"
		else:
			if number == 3 :
				ANIM_IDLE = "No"
			else: 
				if number == 4 :
					ANIM_IDLE = "Yes"
				else:
					if number == 5 :
						ANIM_IDLE = "Bite_InPlace"
	animation_player.play(ANIM_IDLE)

func update_health(health_damage):
	health -= health_damage
	if health == 0:
		death_sound.play()
		animation_player.play("Death")
		# queue_free()
	if health > 0:
		hit_receive.play()
		is_locked = true
		animation_player.play("HitRecieve")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_on_floor():
		is_in_air = true
		velocity.y -= gravity * delta
	else:
		if is_in_air :
			is_in_air = false
			animation_player.play("Jump")
			
	if health > 0 and GameState.is_player_dead == false:				
		if !animation_player.is_playing():
			is_locked = false
				
		var player_position = GameState.player.global_position
		var distance_to_player = global_transform.origin.distance_to(player_position)
		
		if (distance_to_player <= 0.5) :
			is_locked = true
			animation_player.play("Bite_Front")
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("player") and can_be_damage:
					GameState.player.hit_sound.play()
					GameState.player_health = GameState.player_health - 1
					can_be_damage = false
					timer.start()
		
		if (distance_to_player <= detection_radius):
			look_at(Vector3(GameState.player.global_position.x,global_position.y,GameState.player.global_position.z), Vector3.UP)
			var direction = global_position.direction_to(GameState.player.global_position)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#velocity = direction * speed
			if not is_locked:
				animation_player.play("Walk")
				move_and_slide()
		else:
			animation_player.play(ANIM_IDLE)
			
func _on_timer_timeout():
	can_be_damage = true
