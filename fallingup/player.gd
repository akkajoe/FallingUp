extends CharacterBody3D

@export var float_speed = 0.2; # How fast the person floats up
@export var drift_speed = 4.0 # How fast the person rifts left to right
@export var drift_smoothness = 5.0 # How smoothly they start drifting

var  target_x_velocity = 0.0;

func _physics_process(delta): # delta is the time since the last frame
	# Upward floating
	velocity.y = float_speed;
	
	# Get horizontal input
	var input_x = Input.get_axis("left","right")
	target_x_velocity = input_x * drift_speed
	# Smoothly interpolate to desired x velocity (lerp)
	velocity.x = lerpf(velocity.x, target_x_velocity, drift_smoothness * delta)
	velocity.z = 0
	print("pos: ", global_position)
	move_and_slide()
	
	
