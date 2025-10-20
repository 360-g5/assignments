extends CharacterBody3D

#movement settings
@export var moveSpeed: float = 30.0
@export var turnSpeed: float = 3.0    
@export var gravity: float = 20.0

# Steering wheel control
var wheel: Node3D = null
var steerAngle: float = 0.0
@export var steerSpeed: float = 120.0      

func _ready():
	var camera = get_node_or_null("Camera3D")
	wheel = camera.get_node_or_null("wheel")

func _physics_process(delta: float) -> void:
	handleMovement()
	applyGravity(delta)
	move_and_slide()
	updateSteeringWheel(delta)

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

#turns wheel
func updateSteeringWheel(delta: float) -> void:
	if Input.is_action_pressed("move_left"):
		steerAngle = (steerAngle + steerSpeed * delta)
	elif Input.is_action_pressed("move_right"):
		steerAngle = (steerAngle - steerSpeed * delta)
	else:
		if steerAngle > 0:
			steerAngle = max(0, steerAngle - steerSpeed * delta)
		elif steerAngle < 0:
			steerAngle = min(0, steerAngle + steerSpeed * delta)
	wheel.rotation_degrees.z = steerAngle 
