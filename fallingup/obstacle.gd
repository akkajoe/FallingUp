extends Area3D

func _ready() -> void:
	var handler = Callable(self, "_on_body_entered")
	if not body_entered.is_connected(handler):
		body_entered.connect(handler)

func _on_body_entered(body: Node) -> void:
	if body.name != "player":
		return

	# glow
	var world_env = get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment
	if world_env and world_env.environment:
		world_env.environment.glow_strength = clamp(world_env.environment.glow_strength + 0.15, 0.0, 5.0)
		print("ADDING GLOW")

	# notify player
	var player = get_tree().get_current_scene().get_node("player")
	player.register_collected_obstacle(self)

	queue_free()
