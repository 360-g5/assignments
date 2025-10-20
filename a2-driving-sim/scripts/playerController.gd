extends CharacterBody3D

#movement settings
@export var moveSpeed: float = 30.0
@export var turnSpeed: float = 5.0    
@export var gravity: float = 20.0


func _physics_process(delta: float) -> void:
	handleMovement()
	applyGravity(delta)
	move_and_slide()

#handle movement inputs
func handleMovement() -> void:
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
	
	#set speed on ground
	if is_on_floor():
		velocity.x = inputDir.x * moveSpeed
		velocity.z = inputDir.z * moveSpeed

func applyGravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
