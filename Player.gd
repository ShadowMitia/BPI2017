extends KinematicBody2D

var speed = Vector2(0, 0)
var velocity = Vector2(0, 0)

var SPEED = 75
var MAX_SPEED = 800

var JUMP_FORCE = 5000
var GRAVITY = Vector2(0, 200)

var direction = 0
var previous_direction = 0

onready var animation_sprite = get_node("Sprite")
onready var robots = get_tree().get_nodes_in_group("Robots")

	
enum FSM {
	RESTING,
	FALLING,
	JUMPING,
	IN_AIR
	MOVING_LEFT,
	MOVING_RIGHT,
	CONTROLLING_ROBOT
	}
	
var current_state = FSM.RESTING
var previous_state = FSM.RESTING 

func _ready():
    set_process(true)
    #set_process_input(true)

#func _input():
#	pass

func do_animation_on_state():
	if (animation_sprite.is_playing()):
		return
	
	if current_state == FSM.RESTING:
		#print("Resting")
		animation_sprite.play("Resting")
	elif current_state == FSM.FALLING:
		#print("Falling")
		animation_sprite.play("Falling")
	elif current_state == FSM.JUMPING:
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
	else:
		print("No animation")
 
func _process(delta):
	if !is_on_floor() and current_state in [FSM.IN_AIR, FSM.JUMPING, FSM.MOVING_LEFT, FSM.MOVING_RIGHT, FSM.RESTING]:
		#print("not on floor and in fsm state")
		if (velocity.y > 0):
			current_state = FSM.FALLING
	else:
		#print("On the floor in resting position")
		current_state = FSM.RESTING
		
	if (Input.is_action_just_pressed("jump") && is_on_floor()):
		current_state = FSM.JUMPING
		velocity.y -= JUMP_FORCE
	else:
		velocity.x = 0
		direction = 0
	
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

	if Input.is_action_just_pressed("player_action"):
		for object in robots:
			var collshape = object.get_node("Area2D/CollisionShape2D")
			if object == null:
				continue
			var collided = get_node("CollisionShape2D").get_shape().collide(get_node("CollisionShape2D").get_global_transform(), collshape.get_shape(), collshape.get_global_transform())
			if collided:
				object.init(self)
				set_process(false)
				set_visible(false)
				set_position(Vector2(10000, 100000))
				object.get_node("CollisionShape2D").set_disabled(false)
				return
	elif Input.is_action_just_pressed("player_echolocation"):
		var echo_lo = get_node("EchoLocation")
		echo_lo.current_state = echo_lo.FSM.ECHOING_START
	elif Input.is_action_just_pressed("player_exit_robot"):
		# can't happen here
		pass
	
	do_animation_on_state()

	velocity += GRAVITY
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	
	move_and_slide(velocity, Vector2(0, -1))
	
	previous_direction = direction
	previous_state = current_state
	
	
