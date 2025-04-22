extends CharacterBody3D

@export var float_speed = 2.0
@export var sink_speed = 2.0
@export var drift_speed = 4.0
@export var drift_smoothness = 5.0
@export var sink_delay = 3.0   # secs without collect : sinking
@export var gameover_delay = 5.0   # secs of sinking : game over
@export var glow_green_threshold = 2.0  # glow level at which we turn green
@onready var mesh := $Node3D/MeshInstance3D as MeshInstance3D
@onready var world_env := get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment

var state = "floating"
var time_since_last_collect = 0.0
var override_mat: StandardMaterial3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	name = "player"
	# install one global override
	var orig = mesh.mesh.surface_get_material(0) as StandardMaterial3D
	if orig == null:
		orig = StandardMaterial3D.new()
	override_mat = orig.duplicate() as StandardMaterial3D
	mesh.material_override = override_mat

func _physics_process(delta):
	time_since_last_collect += delta

	if state == "floating" and time_since_last_collect >= sink_delay:
		state = "sinking"
		# subtract glow
		world_env.environment.glow_strength = clamp(
			world_env.environment.glow_strength - 0.15, 0.0, 5.0
		)
		time_since_last_collect = 0.0
		print("No collections for %.1f s — sinking!" % sink_delay)

	# Check for green glow threshold
	if world_env.environment.glow_strength >= glow_green_threshold:
		override_mat.albedo_color = Color(0, 1, 0)  # turn the player green
		state = "gameover"

	# movement
	match state:
		"floating": velocity.y = float_speed
		# Add gravity 
		"sinking": velocity.y -= gravity * delta
		#"sinking":  velocity.y = -sink_speed
		"gameover": velocity = Vector3.ZERO

	var in_x = Input.get_axis("left","right")
	velocity.x = lerpf(velocity.x, in_x * drift_speed, drift_smoothness * delta)
	move_and_slide()

	if state == "sinking" and time_since_last_collect >= gameover_delay:
		state = "gameover"
		print("GAME OVER")
		override_mat.albedo_color = Color(1, 0, 0)  # on game over, red

func register_collected_obstacle(_obs: Node) -> void:
	state = "floating"
	time_since_last_collect = 0.0
	# on collect we bump glow up
	world_env.environment.glow_strength = clamp(
		world_env.environment.glow_strength + 0.15, 0.0, 5.0
	)
	print("Collected! Glow is now ", world_env.environment.glow_strength)
	# reset color back to white whenever you collect
	#override_mat.albedo_color = Color(1, 1, 1, 1)
