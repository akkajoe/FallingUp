# obstacle.gd
extends Area3D

func _ready() -> void:
	var handler = Callable(self, "_on_body_entered")
	if not body_entered.is_connected(handler):
		body_entered.connect(handler)

func _on_body_entered(body: Node) -> void:
	if body.name != "player":
		return

	# 1) Find the WorldEnvironment node in the current scene
	var world_env_node := get_tree().get_current_scene().get_node("WorldEnvironment") as WorldEnvironment
	if world_env_node:
		# 2) Grab its Environment resource
		var env := world_env_node.environment
		if env:
			# 3) Bump the glow
			env.glow_strength = clamp(env.glow_strength + 0.20, 0.0, 5.0)

	# 4) Remove this obstacle
	queue_free()
