# player.gd
extends CharacterBody3D

@export var float_speed = 2.0
@export var sink_speed: = 2.0
@export var drift_speed = 4.0
@export var drift_smoothness = 5.0
@export var sink_delay = 5.0  # seconds until sinking

var state  = "floating"
var time_since_last_collect = 0.0

func _ready():
	name = "player"  # ensure the scene node is named "player"

func _physics_process(delta):
	time_since_last_collect += delta
	
	if state == "floating":
		time_since_last_collect += delta
		if time_since_last_collect >= sink_delay:
			state = "sinking"
			print("No collections for %.1f s — sinking!" % sink_delay)

	# vertical
	match state:
		"floating": velocity.y = float_speed
		"sinking":  velocity.y = -sink_speed
		"gameover": velocity = Vector3.ZERO

	# horizontal
	var in_x = Input.get_axis("left","right")
	velocity.x = lerpf(velocity.x, in_x * drift_speed, drift_smoothness * delta)
	move_and_slide()

# auto‐gameover if you sink for  too long
	if state == "sinking" and time_since_last_collect >= 10.0:
		state = "gameover"
		print("Game Over!")	#

func register_collected_obstacle(_obs: Node) -> void:
	# reset to floating on any collect
	state = "floating"
	time_since_last_collect = 0.0
	print("Collected! Back to floating.")
