extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const RADIUS = 30
export(int) onready var radius = RADIUS
export(bool) var drawing = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)

func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
	if (Input.is_action_just_pressed("player_action")):
		drawing = true
		
	if (drawing):
		radius += 5
		if (radius > 300):
			radius = RADIUS
			drawing = false
	update()
	
	
func _draw():
	if (drawing):
		draw_circle_arc(Vector2(0, 0), radius, 0, 360, Color(255, 0, 0))

func draw_circle_arc( center, radius, angle_from, angle_to, color ):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points+1):
        var angle_point = angle_from + i*(angle_to-angle_from)/nb_points - 90
        var point = center + Vector2( cos(deg2rad(angle_point)), sin(deg2rad(angle_point)) ) * radius
        points_arc.push_back( point )

    for indexPoint in range(nb_points):
        draw_line(points_arc[indexPoint], points_arc[indexPoint+1], color)
		