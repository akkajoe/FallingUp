# Character.gd
extends Node3D

func _ready():
	start_ragdoll()  # nothing for now

func start_ragdoll():
	for child in get_children():
		if child is PhysicalBone3D:
			child.physical_bone_active = true

func _on_hit():
	# Example function: call this when character is hit
	start_ragdoll()
