extends Node3D

@export var chunk_scene = preload("res://chunk.tscn")
@export var chunk_spacing = 80.0

var max_y_position = 0.0
var chunk_count = 0

func _ready():
	# Reset chunk state
	max_y_position = 0.0
	chunk_count = 0
	Chunk.global_positions.clear()

	# Spawn initial chunks
	for i in range(6):
		spawn_chunk()
		max_y_position += chunk_spacing


func _process(_delta):
	if $player.global_position.y > max_y_position - chunk_spacing * 5:
		spawn_chunk()
		max_y_position += chunk_spacing

func spawn_chunk():
	var chunk = chunk_scene.instantiate()
	chunk.name = "chunk_%d" % chunk_count  # Assign unique name
	chunk_count += 1
	add_child(chunk)
	chunk.position.y = max_y_position

func _on_obstacle_body_entered(body: Node) -> void:
	print("Collision with:", body.name)

func reset_game():
	await get_tree().create_timer(0.5).timeout  # Optional short delay
	get_tree().reload_current_scene()
