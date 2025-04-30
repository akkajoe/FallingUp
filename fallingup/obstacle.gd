extends Area3D

@onready var mesh = $MeshInstance3D
@onready var camera : Camera3D = get_viewport().get_camera_3d()

@export var obstacle_textures: Array[Texture2D] = [
	preload("res://assets/char/clock.png"),
	preload("res://assets/char/cal.png"),
	preload("res://assets/char/stickynotes.png")
]

func _ready():
	# Assign random texture
	var chosen_texture = obstacle_textures[randi() % obstacle_textures.size()]
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = chosen_texture
	mat.flags_unshaded = true
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.set_surface_override_material(0, mat)

	# Connect signal
	var handler = Callable(self, "_on_body_entered")
	if not body_entered.is_connected(handler):
		body_entered.connect(handler)

func _process(_delta):
	if camera and mesh:
		var mesh_pos = mesh.global_transform.origin
		var camera_pos = camera.global_transform.origin
		camera_pos.y = mesh_pos.y  # keep level

		var direction = (camera_pos - mesh_pos).normalized()
		var angle = atan2(direction.x, direction.z)
		mesh.rotation.y = angle

func _on_body_entered(body: Node) -> void:
	if body.name != "player":
		return

	var world_env = get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment
	if world_env and world_env.environment:
		world_env.environment.glow_strength = clamp(
			world_env.environment.glow_strength + 0.15, 0.0, 5.0
		)
		print("ADDING GLOW")

	var player = get_tree().get_current_scene().get_node("player")
	player.register_collected_obstacle(self)

	queue_free()
