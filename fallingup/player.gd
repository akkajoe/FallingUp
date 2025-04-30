extends CharacterBody3D

@export var float_speed = 4.5
@export var drift_speed = 4.0
@export var acc_x = 4.0
@export var sink_delay = 4.0
@export var glow_green_threshold = 2.0
@export var glow_fall_rate := 0.1
@export var ground_delay = 2.0

@export var push_strength = 6.0
@export var knockback_duration = 1.0

@export var bounce_restitution = 0.8
@export var restitution_decay = 0.2
@export var min_bounce_speed = 0.5

const BOUNCE_IMPULSE = 8.0

var current_turn_speed = 0.0
var state = "floating"
var time_since_last_collect = 0.0
var _ground_contact_started = false
var _ground_contact_time = 0.0

var in_knockback = false
var knockback_velocity = 0.0
var knockback_timer = 0.0

var override_mats : Array[StandardMaterial3D] = []

@onready var world_env = get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var collided_with_obstacle = false
var ragdoll_started = false
var spin_fall = false

func _ready():
	name = "player"
	for m in get_children():
		if m is MeshInstance3D:
			var orig = m.mesh.surface_get_material(0) as StandardMaterial3D
			if orig == null:
				orig = StandardMaterial3D.new()
			var dup = orig.duplicate() as StandardMaterial3D
			m.set_surface_override_material(0, dup)
			override_mats.append(dup)

func _set_color(c) -> void:
	for mat in override_mats:
		mat.albedo_color = c

func _handle_sideways(delta):
	var input_x = -Input.get_axis("left", "right")

	if input_x != 0:
		# Player input overrides knockback
		var target_x = input_x * drift_speed
		current_turn_speed = move_toward(current_turn_speed, target_x, acc_x * delta)
		velocity.x = current_turn_speed
		in_knockback = false
	else:
		if in_knockback:
			velocity.x = knockback_velocity
		else:
			velocity.x = current_turn_speed

func _physics_process(delta):
	time_since_last_collect += delta

	# EARLY RETURN if ragdoll
	if ragdoll_started:
		return

	# FLOATING → SINKING
	if state == "floating" and time_since_last_collect >= sink_delay:
		state = "sinking"
		time_since_last_collect = 0.0

	# WIN (green) check
	if state != "gameover" and world_env.environment.glow_strength >= glow_green_threshold:
		state = "gameover"
		_set_color(Color(0,1,0))
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Freeze if gameover
	if state == "gameover":
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# VERTICAL movement
	if state == "floating":
		velocity.y = float_speed
	else:
		velocity.y -= gravity * delta
		if not is_on_floor():
			world_env.environment.glow_strength = clamp(
				world_env.environment.glow_strength - glow_fall_rate * delta,
				0.0, glow_green_threshold
			)

	var was_on_floor = is_on_floor()

	_handle_sideways(delta)

	move_and_slide()

	var now_on_floor = is_on_floor()

	# Normal bounce landing
	if state == "sinking" and not was_on_floor and now_on_floor:
		var incoming = -velocity.y
		var bounced = incoming * bounce_restitution
		if bounced > min_bounce_speed and bounce_restitution > 0.0:
			velocity.y = bounced
			bounce_restitution = max(bounce_restitution - restitution_decay, 0.0)
		else:
			state = "floating"
			velocity.y = float_speed

	# GROUND-CONTACT lose check
	if state == "sinking" and is_on_floor():
		if not _ground_contact_started:
			_ground_contact_started = true
			_ground_contact_time = 0.0
		else:
			_ground_contact_time += delta
			if _ground_contact_time >= ground_delay:
				state = "gameover"
				_set_color(Color(1,0,0))
				velocity = Vector3.ZERO
				print("GAME OVER: on ground for %.1f s" % ground_delay)
		return
	else:
		_ground_contact_started = false

func register_collected_obstacle(_obs: Node) -> void:
	state = "floating"
	time_since_last_collect = 0.0
	_ground_contact_started = false

	world_env.environment.glow_strength = clamp(
		world_env.environment.glow_strength + 0.02,
		0.0, glow_green_threshold
	)
	_set_color(Color(1,1,1))
	print("Collected! Glow is now ", world_env.environment.glow_strength)

	var dir = (global_position - _obs.global_position).normalized()
	knockback_velocity = dir.x * push_strength
	knockback_timer = knockback_duration
	in_knockback = true

	collided_with_obstacle = true
	spin_fall = true
