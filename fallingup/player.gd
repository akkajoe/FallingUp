extends CharacterBody3D
@export var gravity = 9.8
@export var speed = 5.0

func _phy_process(delta):
	# Apply gravity to y-axis
	velocity.y -= gravity * delta
	# Left and right input x-axis
	var input_x = Input.get_axis("left", "right")
	velocity.x = input_x * speed
	velocity.z = 0
	move_and_slide()
