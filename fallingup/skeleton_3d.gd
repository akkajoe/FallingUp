extends Skeleton3D
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		physical_bones_start_simulation()
