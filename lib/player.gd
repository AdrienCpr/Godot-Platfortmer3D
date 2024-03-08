extends CharacterBody3D

@onready var camera_mout = $camera_mount
@onready var animation_player = $visuals/Character_Gun/AnimationPlayer
@onready var gun:MeshInstance3D = $visuals/Character_Gun/CharacterArmature/Skeleton3D/Gun/Gun
@onready var visuals = $visuals
@onready var raycast:RayCast3D = $camera_mount/RayCast3D
@onready var crossair:Control = $Crossair
@onready var timer_death:Timer = $TimerDeath
@onready var gun_sound:AudioStreamPlayer3D = $GunSound
@onready var hit_sound:AudioStreamPlayer3D = $Hit
@onready var death_sound:AudioStreamPlayer3D = $Death

@export var mouse_sensitivity_x = 0.05
@export var mouse_sensitivity_y = 0.05

signal iteraction_detected(node:Node3D)
signal iteraction_detected_end(node:Node3D)

var SPEED = 5.0
var HEALTH = 3
const JUMP_VELOCITY = 4.5
var walking_speed = 3
var running_speed = 6

const ANIM_IDLE = "Idle"
const ANIM_WALK = "Walk"
const ANIM_RUN = "Run"

const ANIM_GUN_IDLE = "Idle_Gun"
const ANIM_GUN_WALK = "Walk_Gun"
const ANIM_GUN_RUN = "Run_Gun"

const ANIM_JUMP_START = "Jump"
const ANIM_JUMP_IDLE = "Jump_Idle"
const ANIM_JUMP_END = "Jump_Land"

const ANIM_PUNCH = "Punch"
const ANIM_IDLE_SHOOT = "Idle_Shoot"
const ANIM_RUN_SHOOT = "Run_Shoot"

const ANIM_EMOTE_HELLO = "Wave"
const ANIM_EMOTE_YES = "Yes"
const ANIM_EMOTE_NO = "No"
const ANIM_EMOTE_DUCK = "Duck"

var mouse_captured:bool = false
var is_running:bool = false
var is_in_air:bool = false
var is_dead:bool = false
var is_locked:bool = false
var is_shoot_gun:bool = false
var has_gun:bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Mouse mouvments
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
	
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_x))
		visuals.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity_x))
		camera_mout.rotate_x(deg_to_rad(event.relative.y * mouse_sensitivity_y))

func player_is_dead():
	death_sound.play()
	animation_player.play("Death")
	is_locked = true
	GameState.is_player_dead = true
	timer_death.start()

func _on_timer_timeout():
	GameState.player_health = 3
	GameState.coins = 0
	GameState.has_key = false
	GameState.is_player_dead = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_area_3d_body_entered(body):
	iteraction_detected.emit(body)

func _on_area_3d_body_exited(body):
	iteraction_detected_end.emit(body)

func _physics_process(delta):
	if mouse_captured == false:
		var joypad_dir:Vector2 = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down")
		if joypad_dir.length() > 0:
			var look_dir = joypad_dir * delta
			rotate_y(-look_dir.x * 2.0)
			camera_mout.rotate_x(-look_dir.y)
			camera_mout.rotation.x = clamp(camera_mout.rotation.x - look_dir.y, -deg_to_rad(75), deg_to_rad(60))
			
	if GameState.player_health <= 0 :
		if GameState.is_player_dead == false:
			player_is_dead()
			
	if !animation_player.is_playing():
		is_locked = false
		is_shoot_gun = false
		
	# Add the gravity.
	if not is_on_floor():
		is_in_air = true
		velocity.y -= gravity * delta
	else:
		if is_in_air :
			is_in_air = false
			animation_player.play(ANIM_JUMP_END)
				
	if Input.is_action_just_pressed("equip_gun"):
		if has_gun: 
			has_gun = false
			crossair.hide()
			gun.hide()
		else:
			has_gun = true
			crossair.show()
			gun.show()
			
	if Input.is_action_just_pressed("emote_hello"):
		if (animation_player.current_animation != ANIM_EMOTE_HELLO) :
				animation_player.play(ANIM_EMOTE_HELLO)
				is_locked = true
				
	if Input.is_action_just_pressed("emote_yes"):
		if (animation_player.current_animation != ANIM_EMOTE_YES) :
				animation_player.play(ANIM_EMOTE_YES)
				is_locked = true
	
	if Input.is_action_just_pressed("emote_no"):
		if (animation_player.current_animation != ANIM_EMOTE_NO) :
				animation_player.play(ANIM_EMOTE_NO)
				is_locked = true
				
	if Input.is_action_just_pressed("emote_duck"):
		if (animation_player.current_animation != ANIM_EMOTE_DUCK) :
				animation_player.play(ANIM_EMOTE_DUCK)
				is_locked = true
				
	if Input.is_action_pressed("player_run"):
		SPEED = running_speed
		is_running = true
	else:
		SPEED = walking_speed
		is_running = false

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("Jump")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("player_hit"):
		if has_gun:
			gun_sound.play()
			if raycast.is_colliding():
				var target = raycast.get_collider()
				
				if target.is_in_group("enemies"):
					target.update_health(5)

			if direction:
				if (animation_player.current_animation != ANIM_RUN_SHOOT) :
					animation_player.play(ANIM_RUN_SHOOT)
					is_locked = true
					is_shoot_gun = true
			else :
				if (animation_player.current_animation != ANIM_IDLE_SHOOT) :
					animation_player.play(ANIM_IDLE_SHOOT)
					is_locked = true
					is_shoot_gun = true
		#else:
			#if (animation_player.current_animation != ANIM_PUNCH) :
				#animation_player.play(ANIM_PUNCH)
				#is_locked = true
				#is_shoot_gun = true
				
	if direction:
		if !is_locked:
			if is_in_air:
				if (animation_player.current_animation != ANIM_JUMP_IDLE) :
						animation_player.play(ANIM_JUMP_IDLE)
			else:
				if has_gun:
					if is_running:
						if (animation_player.current_animation != ANIM_GUN_RUN) :
							animation_player.play(ANIM_GUN_RUN)
					else:
						if (animation_player.current_animation != ANIM_GUN_WALK) :
							animation_player.play(ANIM_GUN_WALK)
				else :
					if is_running:
						if (animation_player.current_animation != ANIM_RUN) :
							animation_player.play(ANIM_RUN)
					else:
						if (animation_player.current_animation != ANIM_WALK) :
							animation_player.play(ANIM_WALK)
			
			visuals.look_at(position + direction)
		
		if GameState.player_health_change == false:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if is_in_air:
				if (animation_player.current_animation != ANIM_JUMP_IDLE) :
						animation_player.play(ANIM_JUMP_IDLE)
			else:
				if has_gun:
					if (animation_player.current_animation != ANIM_GUN_IDLE) :
						animation_player.play(ANIM_GUN_IDLE)
				else:
					if (animation_player.current_animation != ANIM_IDLE) :
						animation_player.play(ANIM_IDLE)
		
		if GameState.player_health_change == false:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked or is_shoot_gun:
		move_and_slide()
