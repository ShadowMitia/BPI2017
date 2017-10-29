extends KinematicBody2D


var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)

var SPEED = 200
var MAX_SPEED = 800

var JUMP_FORCE = 50000
var GRAVITY = Vector2(0, 200)

var direction = 0
var previous_direction = 0

var player_ref = null

onready var animation_sprite = get_node("Sprite")

enum RobotType {
	SHIELD,
	TACTICAL,
	ELEVATOR,
	HOVERBOARD
	}
	
var robot_type = null

var booted = false
var initialised = false

enum FSM {
	RESTING,
	FALLING,
	JUMPING,
	IN_AIR
	MOVING_LEFT,
	MOVING_RIGHT,
	ACTIVATING,
	PLAYER_CLIMB_ON,
	PLAYER_CLIMB_OFF
	}
	
var current_state = FSM.RESTING
var previous_state = FSM.RESTING

func init(player, robot_type):
	robot_type = robot_type
	player_ref = player
	initialised = true
	get_node("Sprite").play("activating")

func give_control_back():
	set_process(false)
	player_ref.set_process(true)
	player_ref.set_visible(true)
	player_ref = null

func _ready():
    set_process(false)

func do_animation_on_state():
	if (animation_sprite.is_playing()):
		return
	
	if current_state == FSM.RESTING:
		print("Resting")
		animation_sprite.play("Resting")
	elif current_state == FSM.FALLING:
		print("Falling")
		animation_sprite.play("Falling")
	elif current_state == FSM.JUMPING:
		print("Resting")
		animation_sprite.play("Resting")
		animation_sprite.play("Jumping")
		current_state = FSM.IN_AIR
	elif current_state in [FSM.MOVING_LEFT, FSM.MOVING_RIGHT]:
		print("Moving")
		animation_sprite.play("Moving")
	elif current_state == FSM.IN_AIR:
		print("In Air")
		animation_sprite.play("Jumping")
	elif current_state == FSM.ACTIVATING:
		pass
	elif current_state == FSM.PLAYER_CLIMB_OFF:
		pass
	elif current_state == FSM.PLAYER_CLIMB_ON:
		pass
	else:
		print("No animation")
		
func do_tactical_process(delta):
	pass

func do_shield_process(delta):
	if (Input.is_action_pressed("move_left")):
		animation_sprite.set_flip_h(true)
		current_state = FSM.MOVING_LEFT
		velocity.x = -SPEED
		direction = -1
	elif (Input.is_action_pressed("move_right")):
		animation_sprite.set_flip_h(false)
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
	pass
	
func do_hoverboard_process(delta):
	pass
 
func _process(delta):
	if (!initialised):
		print("NOT INITIALISED")
	
	if !is_on_floor() and current_state in [FSM.IN_AIR, FSM.JUMPING, FSM.MOVING_LEFT, FSM.MOVING_RIGHT, FSM.RESTING]:
		print("not on floor and in fsm state")
		if (velocity.y > 0):
			current_state = FSM.FALLING
	else:
		print("On the floor in resting position")
		current_state = FSM.RESTING
	
	if robot_type == RobotType.SHIELD:
		do_shield_process(delta)
	else:
		print("todo")
	
	#if (Input.is_action_pressed("move_left")):
	#	animation_sprite.set_flip_h(true)
	#	current_state = FSM.MOVING_LEFT
	#	velocity.x = -SPEED
	#	direction = -1
	#elif (Input.is_action_pressed("move_right")):
	#	animation_sprite.set_flip_h(false)
	#	current_state = FSM.MOVING_RIGHT
	#	velocity.x = SPEED
	#	direction = 1
	#elif (Input.is_action_just_pressed("jump") && is_on_floor()):
	#	current_state = FSM.JUMPING
	#	velocity.y -= JUMP_FORCE
	#else:
	#	velocity.x = 0
	#	direction = 0
	
	if Input.is_action_just_pressed("player_action"):
		pass
	elif Input.is_action_just_pressed("player_echolocation"):
		# don't do it here!
		pass
	elif Input.is_action_just_pressed("player_exit_robot"):
		give_control_back()
		
	# do_animation_on_state()

	velocity += GRAVITY
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	
	move_and_slide(velocity, Vector2(0, -1))
	
	previous_direction = direction
	previous_state = current_state
	
	
