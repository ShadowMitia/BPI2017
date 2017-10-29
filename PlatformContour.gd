extends CollisionShape2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var contour = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	update()

func _draw():
	if contour:
		var pos = get_position() - get_shape().get_extents()
		var size = get_shape().get_extents() * 2
		draw_rect(Rect2(pos, size), Color(255, 0, 0), false)
		if not get_node("../EchoResponse").is_playing():
			get_node("../EchoResponse").play()
	else:
		get_node("../EchoResponse").stop()
