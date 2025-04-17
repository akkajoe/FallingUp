extends Node3D

@export var chunk_scene: PackedScene = preload("res://chunk.tscn")
@export var chunk_spacing = 80.0

var max_y_position = 0.0
var chunk_count = 0

func _process(_delta):
	if $player.global_position.y > max_y_position - chunk_spacing * 5:
		spawn_chunk()
		max_y_position += chunk_spacing

func spawn_chunk():
	var chunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.position.y = max_y_position

func _on_obstacle_body_entered(body: Node) -> void:
	# this will be called when the player hits an obstacle
	print("Collision with:", body.name)
