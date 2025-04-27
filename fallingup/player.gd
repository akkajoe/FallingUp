extends CharacterBody3D

@export var float_speed = 4.5
@export var sink_speed = 2.0
@export var drift_speed = 4.0
@export var drift_smoothness = 5.0
@export var sink_delay = 5.0
@export var glow_green_threshold = 2.0

@export var glow_fall_rate := 0.1    # glow units lost per second while sinking
@export var ground_delay = 2.0       # seconds on ground before red

@onready var mesh      = $Node3D/MeshInstance3D as MeshInstance3D
@onready var world_env = get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment

# acceleration in the x-axis when the direction turns
@export var acc_x = 4.0
# keep track of your current sideways speed
var current_turn_speed = 0.0

var state = "floating"
var time_since_last_collect = 0.0

var _ground_contact_started = false
var _ground_contact_time = 0.0

var override_mat: StandardMaterial3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	name = "player"
	var orig = mesh.mesh.surface_get_material(0) as StandardMaterial3D
	if orig == null:
		orig = StandardMaterial3D.new()
	override_mat = orig.duplicate() as StandardMaterial3D
	mesh.material_override = override_mat


func _physics_process(delta):
	time_since_last_collect += delta

	# — start sinking if no collection —
	if state == "floating" and time_since_last_collect >= sink_delay:
		state = "sinking"
		time_since_last_collect = 0.0
		print("No collections for %.1f s — sinking!" % sink_delay)

	# — win immediately if glow too high —
	if world_env.environment.glow_strength >= glow_green_threshold:
		override_mat.albedo_color = Color(0, 1, 0)
		state = "gameover"
		return

	# — continuous fade while falling (before hitting ground) —
	if state == "sinking" and not is_on_floor():
		velocity.y -= gravity * delta
		world_env.environment.glow_strength = clamp(
			world_env.environment.glow_strength - glow_fall_rate * delta,
			0.0, glow_green_threshold
		)

	# — ground-hit timer & game-over logic —
	if state == "sinking" and is_on_floor():
		if not _ground_contact_started:
			print("CHECK")
			_ground_contact_started = true
			_ground_contact_time = 0.0
		else:
			_ground_contact_time += delta
			print("CHECK2")
			if _ground_contact_time >= ground_delay:
				# you can swap in your bounce or game-over tweak here
				override_mat.albedo_color = Color(1, 0, 0)
				print("GAME OVER: on ground for %.1f s" % ground_delay)
		return
	else:
		_ground_contact_started = false

	# — vertical movement based on state —
	match state:
		"floating":
			velocity.y = float_speed
		"sinking":
			pass
		"gameover":
			velocity = Vector3.ZERO

	# — X-axis steering with acceleration —
	var in_x = Input.get_axis("left", "right")
	var target_turn_speed = in_x * drift_speed
	current_turn_speed = move_toward(current_turn_speed, target_turn_speed, acc_x * delta)
	velocity.x = current_turn_speed

	# — apply the slide (Godot 4 style) —
	move_and_slide()


func register_collected_obstacle(_obs: Node) -> void:
	state = "floating"
	time_since_last_collect = 0.0
	_ground_contact_started = false
	world_env.environment.glow_strength = clamp(
		world_env.environment.glow_strength + 0.02,
		0.0, glow_green_threshold
	)
	override_mat.albedo_color = Color(1, 1, 1)
	print("Collected! Glow is now ", world_env.environment.glow_strength)
