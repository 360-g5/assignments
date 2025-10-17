#create a camera3d node and attach as child to main 3dnode
#in project, project settings, set up input handling
extends Camera3D

#movement settings
@export var moveSpeed: float = 50.0
@export var verticalSpeed: float = 30.0
#@export var turnSpeed: float = 0.5
@export var turnSpeed: float = 1.0    

var velocity: Vector3 = Vector3.ZERO

func _process(delta: float) -> void:
	handleMovement(delta)

#handle movement inputs
func handleMovement(delta: float) -> void:
	var inputDir := Vector3.ZERO

	if Input.is_action_pressed("move_forward"): 
		inputDir -= transform.basis.z
	if Input.is_action_pressed("move_backward"): 
		inputDir += transform.basis.z

	if Input.is_action_pressed("move_left"):  
		rotate_y(deg_to_rad(turnSpeed))
	if Input.is_action_pressed("move_right"): 
		rotate_y(deg_to_rad(-turnSpeed))

	#normalize to prevent faster diagonal movement
	if inputDir.length() > 0:
		inputDir = inputDir.normalized()

	#apply movement
	position += inputDir * moveSpeed * delta
