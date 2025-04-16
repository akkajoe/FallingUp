extends Node3D

@export var chunk_height = 100.0
@export var obstacle_scene: PackedScene = preload("res://obstacle.tscn")
@export var number_of_obstacles: int = 150

func _ready():
	spawn_obstacles()

func spawn_obstacles():
	var placed_positions: Array[Vector3] = []
	const SAFE_RADIUS = 4.0
	var attempts = 0
	var max_attempts = number_of_obstacles * 3

	while placed_positions.size() < number_of_obstacles and attempts < max_attempts:
		attempts += 1

		if randf() > 0.4:
			var random_x = randf_range(-30, 30)
			var random_y = global_position.y + randf_range(0, chunk_height)
			var random_z = position.z
			var new_pos = Vector3(random_x, random_y, random_z)

			var too_close = false
			for pos in placed_positions:
				if pos.distance_to(new_pos) < SAFE_RADIUS * 2.0:
					too_close = true
					break

			if not too_close:
				var obstacle = obstacle_scene.instantiate()
				add_child(obstacle)
				obstacle.position = new_pos
				placed_positions.append(new_pos)
				#print("OBSTACLE PLACED AT:", new_pos)
