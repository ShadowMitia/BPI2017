extends KinematicBody2D

const RADIUS = 30
onready var radius = RADIUS

onready var collision = get_node("CollisionShape2D")
onready var collisionObjects = get_tree().get_nodes_in_group("echolocation")
var collidedObjects = Dictionary()

var emission_coordinate = Vector2(0, 0)

enum FSM {
	ECHOING_START,
	ECHOING,
	ECHOING_END,
	STOP
	}
	
onready var current_state = FSM.STOP

func update_collision():
	collision.get_shape().set_radius(radius)
	var prevsize = collisionObjects.size()
	for object in collisionObjects:
		var collshape = object.get_node("CollisionShape2D")
		var points = collision.get_shape().collide_and_get_contacts(collision.get_global_transform(), collshape.get_shape(), collshape.get_global_transform())
		if (points == null):
			continue
		collidedObjects[object] = object
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
func _process(delta):
	if (current_state == FSM.ECHOING_START):
		emission_coordinate = Vector2(0, 0)
		current_state = FSM.ECHOING
		get_node("StartingEcho").play()
	elif (current_state == FSM.ECHOING):
		update_collision()
		radius += 5
		if (radius > 300):
			current_state = FSM.ECHOING_END
		for obj in collidedObjects.values():
			obj.get_node("CollisionShape2D").contour = true
	elif (current_state == FSM.ECHOING_END):
		radius = RADIUS
		current_state = FSM.STOP
		get_node("StartingEcho").stop()
		
	else:
		for object in collidedObjects.values():
			object.get_node("CollisionShape2D").contour = false
		collidedObjects.clear()
	update()
	
func _draw():
	if (current_state == FSM.ECHOING):
		draw_circle_arc(emission_coordinate, radius, 0, 360, Color(255, 0, 0))

func draw_circle_arc( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = PoolVector2Array()
    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
        points_arc.push_back( point )
    for indexPoint in range(nb_points):
        draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)


