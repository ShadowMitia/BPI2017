extends KinematicBody2D


var speed = Vector2()
var velocity = Vector2()

var SPEED = 75
var MAX_SPEED = 800

var JUMP_FORCE = 5000
var GRAVITY = 100

var direction = 0
var previous_direction = 0

onready var animation_sprite = get_node("Sprite")
 
func _ready():
    set_process(true)
    set_process_input(true)

func _input():
	pass
 
func _process(delta):
	if (Input.is_action_pressed("move_left")):
		animation_sprite.set_flip_h(true)
		animation_sprite.set_animation("Moving")
		velocity.x = -SPEED
		direction = -1
	elif (Input.is_action_pressed("move_right")):
		animation_sprite.set_flip_h(false)
		animation_sprite.set_animation("Moving")
		velocity.x = SPEED
		direction = 1
	else:
		velocity.x = 0
		direction = 0
		
	if (Input.is_action_just_pressed("jump") && is_on_floor()):
		animation_sprite.set_animation("Jumping")
		velocity.y -= JUMP_FORCE
		velocity.x += 200 * direction
	else:
		if (is_on_floor()):
			animation_sprite.set_animation("Resting")
		else:
			if (velocity.y > 0):
				animation_sprite.set_animation("Falling")
		velocity.y += GRAVITY
	
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
	
	move_and_slide(velocity, Vector2(0, -1))
	
	previous_direction = direction
	
	
