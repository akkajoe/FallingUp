extends CharacterBody3D

@export var float_speed = 2; # How fast the person floats up
@export var drift_speed = 4.0 # How fast the person rifts left to right
@export var drift_smoothness = 5.0 # How smoothly they start drifting

var  target_x_velocity = 0.0;
var bump_count = 0
var max_brightness = 5.0  # cap brightness to prevent nuclear glow
var emission_base_color = Color(1.0, 0.5, 0.2)  # orange glow
var material: StandardMaterial3D
var last_bump_frame = -1


func _ready():
	var mesh = $Node3D/playerMesh  # or whatever your mesh node is called
	if mesh.material_override and mesh.material_override is StandardMaterial3D:
		material = mesh.material_override
		material.emission_enabled = true
		material.emission_energy = 0.1
		print("innnnnnn")
	else:
		push_error("Player mesh is missing a proper StandardMaterial3D override!")
	

func _physics_process(delta): # delta is the time since the last frame
	# Upward floating
	velocity.y = float_speed;
	
	# Get horizontal input
	var input_x = Input.get_axis("left","right")
	target_x_velocity = input_x * drift_speed
	# Smoothly interpolate to desired x velocity (lerp)
	velocity.x = lerpf(velocity.x, target_x_velocity, drift_smoothness * delta)
	velocity.z = 0
	#print("pos: ", global_position)
	
	if get_slide_collision_count() > 0 and last_bump_frame != Engine.get_physics_frames():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider():  # Optional: further check tag/group/etc
				bump_count += 1
				last_bump_frame = Engine.get_physics_frames()

				var intensity = clamp(0.1 + bump_count * 0.2, 0.1, max_brightness)
				material.emission_energy = intensity
				print("Bump #", bump_count, "- brightness:", intensity)
				print("Player scale:", scale)
				break  # only count one collision per frame


		
	move_and_slide()
	
	
