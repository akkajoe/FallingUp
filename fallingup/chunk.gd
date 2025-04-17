# chunk.gd  (attach to each Chunk scene root; Node3D)
extends Node3D

@export var chunk_height  = 100.0
@export var obstacle_scene = preload("res://obstacle.tscn")
@export var obstacles_per_chunk = 800

# shared across all chunks, only for spacing checks:
static var global_positions: Array[Vector3] = []

func _ready() -> void:
	spawn_obstacles()


func spawn_obstacles() -> void:
	const SAFE_RADIUS = 4.0 # minimum safe radius between two obstacles
	var placed_in_this_chunk = 0 # NUmber of obstacles successfully placed
	var attempts = 0 # Number of tries
	# allow a few tries *per obstacle*
	var max_attempts = obstacles_per_chunk * 5 # Allow the loop to iterate these many times to find pos

	while placed_in_this_chunk < obstacles_per_chunk and attempts < max_attempts:
		attempts += 1

		if randf() > 0.2: # 80 percent of loops try placing
			var new_pos = Vector3(
				randf_range(-40, 40),
				global_position.y + randf_range(0, chunk_height),
				global_position.z
			)

			# obstacle merge avoidance
			var too_close = false
			for pos in global_positions:
				if pos.distance_to(new_pos) < SAFE_RADIUS * 2.0:
					too_close = true
					break
			if too_close:
				continue

			# place it
			var obstacle = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = new_pos

			# record for both local count and global spacing
			placed_in_this_chunk += 1
			global_positions.append(new_pos)
