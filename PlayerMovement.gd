extends KinematicBody2D


var speed = Vector2()
var velocity = Vector2()

var ACCELERATION = 1000
var MAX_SPEED = 600

var direction = 0
var previous_direction = 0
 
func _ready():
    set_process(true)
    set_process_input(true)

func _input():
	pass
 
func _process(delta):
	
	if (Input.is_action_pressed("move_left")):
		velocity.x = -ACCELERATION
		direction = -1
	elif (Input.is_action_pressed("move_right")):
		velocity.x = ACCELERATION
		direction = 1
	else:
		velocity.x = 0
		direction = 0

	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	
	move_and_slide(velocity)
	
	
