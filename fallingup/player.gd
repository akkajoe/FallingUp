# player.gd
extends CharacterBody3D

@export var float_speed            = 4.5
@export var drift_speed            = 4.0
@export var acc_x                  = 4.0
@export var sink_delay             = 6.0
@export var glow_green_threshold   = 2.0
@export var glow_fall_rate   := 0.1    # glow units lost per second while sinking

@export var push_strength          = 6.0    # how hard we get knocked sideways
@export var knockback_duration     = 1.0    # force override lasts exactly 1 s

@export var bounce_restitution     = 0.8    # fraction of downward speed retained on bounce
@export var min_bounce_speed       = 0.2    # if bounce would be smaller, stop bouncing

const BOUNCE_IMPULSE : float = 8.0

var current_turn_speed       = 0.0
var state                    = "floating"
var time_since_last_collect  = 0.0
var _ground_contact_started  = false
var _ground_contact_time     = 0.0

# knock-back state
var in_knockback             = false
var knockback_velocity       = 0.0
var knockback_timer          = 0.0

@onready var mesh            = $Node3D/MeshInstance3D as MeshInstance3D
@onready var world_env       = get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment

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

	# — sinking trigger —
	if state == "floating" and time_since_last_collect >= sink_delay:
		state = "sinking"
		time_since_last_collect = 0.0

	# — win (green) check —
	if state != "gameover" and world_env.environment.glow_strength >= glow_green_threshold:
		state = "gameover"
		override_mat.albedo_color = Color(0,1,0)
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# — freeze on gameover —
	if state == "gameover":
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# — vertical: float up vs fall —
	if state == "floating":
		velocity.y = float_speed
	else:
		velocity.y -= gravity * delta
		if not is_on_floor():
			world_env.environment.glow_strength = clamp(
				world_env.environment.glow_strength - glow_fall_rate * delta,
				0.0, glow_green_threshold
			)

	# — track floor before move —
	var was_on_floor = is_on_floor()

	# — sideways: knockback override or normal drift —
	if in_knockback:
		velocity.x = knockback_velocity
		knockback_timer -= delta
		if knockback_timer <= 0:
			in_knockback = false
			current_turn_speed = 0.0
	else:
		var input_x = -Input.get_axis("left", "right")  # correct axis
		var target_x = input_x * drift_speed
		current_turn_speed = move_toward(current_turn_speed, target_x, acc_x * delta)
		velocity.x = current_turn_speed

	# — move the body —
	move_and_slide()

	# — bounce like a ball when you hit ground —
	if state == "sinking" and not was_on_floor and is_on_floor():
		var new_vy = abs(velocity.y) * bounce_restitution
		if new_vy > min_bounce_speed:
			velocity.y = new_vy
		else:
			# bounce too small → switch back to floating
			state = "floating"
			velocity.y = float_speed


func register_collected_obstacle(_obs: Node) -> void:
	# — reset glow & state —
	state = "floating"
	time_since_last_collect = 0.0
	_ground_contact_started = false
	world_env.environment.glow_strength = clamp(
		world_env.environment.glow_strength + 0.02,
		0.0, glow_green_threshold
	)
	override_mat.albedo_color = Color(1,1,1)

	# — vertical bounce impulse —
	velocity.y = BOUNCE_IMPULSE

	# — sustained sideways knock-back —
	var dir = (global_position - _obs.global_position).normalized()
	knockback_velocity = dir.x * push_strength
	knockback_timer = knockback_duration
	in_knockback = true
