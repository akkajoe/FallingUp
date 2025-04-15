extends Camera3D
@export var target_path : NodePath # This is the node that the camera follows
@export var offset = Vector3.ZERO # How far the camera should stay away from the target
var target = null
func _ready():
	if target_path:
		target = get_node(target_path)
		position = target.position + offset
		look_at(target.position) # Rotates the camera to always face the target
func _physics_process(_delta):
	if !target:
		return
	position = target.position + offset # The camera's position is updated every physics frame
