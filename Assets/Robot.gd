extends KinematicBody2D

var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)

var SPEED = 100
var MAX_SPEED = 800

var JUMP_FORCE = 50000
var GRAVITY = Vector2(0, 200)

var direction = 0
var previous_direction = 0

var player_ref = null

var animation_sprite = null

var antigravity = false

var animation_running = false

enum RobotType {
	SHIELD,
	TACTICAL,
	ELEVATOR,
	HOVERBOARD
	}
	
export(String) var editorRobotType
	
var robot_type = null

var booted = false
var initialised = false

var has_player = false

enum FSM {
	RESTING,
	FALLING,
	JUMPING,
	IN_AIR
	MOVING_LEFT,
	MOVING_RIGHT,
	ACTIVATING,
	PLAYER_CLIMB_ON,
	PLAYER_CLIMB_OFF,
	OFFLINE
	}
	
var current_state = FSM.OFFLINE
var previous_state = FSM.OFFLINE

func init(player):
	player_ref = player
	initialised = true
	current_state = FSM.ACTIVATING
	set_process(true)
	has_player = true
	do_animation_on_state()

func give_control_back():
	get_node("CollisionShape2D").set_disabled(true)
	player_ref.set_process(true)
	player_ref.set_visible(true)
	player_ref.set_position(get_position())
	player_ref = null
	has_player = false
	set_process(false)
	do_animation_on_state()

func _ready():
	get_node("CollisionShape2D").set_disabled(true)
	get_node("SpriteShield").set_visible(false)
	get_node("SpriteVertigo").set_visible(false)
	
	set_process(false)
	if (editorRobotType.to_lower() == "shield"):
		print("SHIELD")
		robot_type = RobotType.SHIELD
		animation_sprite = get_node("SpriteShield")
	elif (editorRobotType.to_lower() == "vertigo"):
		robot_type = RobotType.ELEVATOR
		animation_sprite = get_node("SpriteVertigo")
	else:
		animation_sprite = get_node("SpriteShield")
		
	animation_sprite.set_visible(true)
		
	do_animation_on_state()
	
func do_animation_on_state():
	if (animation_running):
		return
	
	if current_state == FSM.RESTING:
		#print("Resting")
		if has_player:
			animation_sprite.play("RestingPlayer")
		else:
			animation_sprite.play("Resting")
	elif current_state == FSM.FALLING:
		#print("Falling")
		animation_sprite.play("Falling")
	elif current_state == FSM.JUMPING:
		animation_running = true
		#print("Resting")
		animation_sprite.play("Resting")
		animation_sprite.play("Jumping")
		current_state = FSM.IN_AIR
	elif current_state in [FSM.MOVING_LEFT, FSM.MOVING_RIGHT]:
		#print("Moving")
		animation_sprite.play("Moving")
	elif current_state == FSM.IN_AIR:
		#print("In Air")
		animation_sprite.play("Jumping")
	elif current_state == FSM.ACTIVATING:
		animation_running = true
		animation_sprite.play("Activating")
		if robot_type == RobotType.ELEVATOR:
			get_node("ActivationSound").play()
		elif robot_type == RobotType.SHIELD:
			get_node("DeployingShield").play()
		booted = true
		current_state = FSM.RESTING
	elif current_state == FSM.PLAYER_CLIMB_OFF:
		animation_running = true
		animation_sprite.play("PlayerOff")
		current_state = FSM.OFFLINE
	elif current_state == FSM.PLAYER_CLIMB_ON:
		animation_running = true
		animation_sprite.play("PlayerOn")
	elif current_state == FSM.OFFLINE:
		animation_sprite.play("Offline")
	else:
		print("No animation")
		
func do_tactical_process(delta):
	pass

func do_shield_process(delta):
	if (Input.is_action_pressed("move_left")):
		animation_sprite.set_flip_h(false)
		current_state = FSM.MOVING_LEFT
		velocity.x = -SPEED
		direction = -1
	elif (Input.is_action_pressed("move_right")):
		animation_sprite.set_flip_h(true)
		current_state = FSM.MOVING_RIGHT
		velocity.x = SPEED
		direction = 1
	elif (Input.is_action_just_pressed("jump") && is_on_floor()):
		# can't jump
		pass
	else:
		velocity.x = 0
		direction = 0
	
func do_elevator_process(delta):
	if Input.is_action_pressed("move_up"):
		set_position(get_position() + Vector2(0, -SPEED))
		if (get_position().y < 0):
			set_position(Vector2(get_position().x, 0))
		antigravity = true
		get_node("ElevatorMovement").play()
	elif Input.is_action_pressed("move_down"):
		set_position(get_position() + Vector2(0, SPEED))
		antigravity = true
		if (get_position().y > OS.get_window_size().y):
			set_position(Vector2(get_position().x, OS.get_window_size().y))
		get_node("ElevatorMovement").play()
	elif (Input.is_action_pressed("move_left")):
		animation_sprite.set_flip_h(false)
		current_state = FSM.MOVING_LEFT
		velocity.x = -SPEED
		direction = -1
		get_node("Movement").play()
	elif (Input.is_action_pressed("move_right")):
		animation_sprite.set_flip_h(true)
		current_state = FSM.MOVING_RIGHT
		velocity.x = SPEED
		direction = 1
		get_node("Movement").play()
	else:
		antigravity = false
		velocity.x = 0
		direction = 0
		get_node("ElevatorMovement").stop()
		get_node("Movement").stop()
	
func do_hoverboard_process(delta):
	pass
	
func _draw():
	if booted:
		print("draw")
		draw_circle(get_parent().get_position(), 50, Color(255, 255, 255))
 
func _process(delta):
	if (!initialised):
		print("NOT INITIALISED")
	
	if booted:
		if !is_on_floor() and current_state in [FSM.PLAYER_CLIMB_OFF, FSM.IN_AIR, FSM.JUMPING, FSM.MOVING_LEFT, FSM.MOVING_RIGHT, FSM.RESTING]:
			#print("not on floor and in fsm state")
			if (velocity.y > 0):
				current_state = FSM.FALLING
		else:
			#print("On the floor in resting position")
			current_state = FSM.RESTING
	
		if robot_type == RobotType.SHIELD:
			do_shield_process(delta)
		elif robot_type == RobotType.ELEVATOR:
			do_elevator_process(delta)
		else:
			print("todo")
		
		if Input.is_action_just_pressed("player_action"):
			pass
		elif Input.is_action_just_pressed("player_echolocation"):
			# don't do it here!
			pass
		elif Input.is_action_just_pressed("player_exit_robot"):
			give_control_back()
		
		do_animation_on_state()
		
		if !antigravity:
			velocity += GRAVITY
		velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
		velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
		
		move_and_slide(velocity, Vector2(0, -1))
		
		previous_direction = direction
		previous_state = current_state
		

func _on_SpriteShield_animation_finished():
	print("finished shield")
	animation_running = false
	get_node("ActivationSound").stop()

func _on_SpriteVertigo_animation_finished():
	print("finished vertigo")
	animation_running = false
	get_node("DeployingShield").stop()
