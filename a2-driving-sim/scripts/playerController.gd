extends CharacterBody3D

#movement settings
@export var moveSpeed: float = 0.0
@export var moveSpeedMax: float = 50.0
@export var turnSpeed: float = 3.0    
@export var gravity: float = 20.0

@export var acceleration: float = 5.0
@export var deceleration: float = 15.0
var lastDir := Vector3.ZERO
var lastDirSign := -1.0
var inputDirSign := -1.0

# Steering wheel control
var wheel: Node3D = null
var steerAngle: float = 0.0
@export var steerSpeed: float = 120.0      

func _ready():
	var camera = get_node_or_null("Camera3D")
	wheel = camera.get_node_or_null("wheel")

func _physics_process(delta: float) -> void:
	handleMovement(delta)
	applyGravity(delta)
	move_and_slide()
	updateSteeringWheel(delta)

#handle movement inputs
func handleMovement(delta: float) -> void:
	var inputDir := Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"): 
		inputDir -= transform.basis.z
		inputDirSign = -1.0
	if Input.is_action_pressed("move_backward"): 
		inputDir += transform.basis.z
		inputDirSign = 1.0
	if Input.is_action_pressed("move_left"):  
		rotate_y(deg_to_rad(turnSpeed))
	if Input.is_action_pressed("move_right"): 
		rotate_y(deg_to_rad(-turnSpeed))
	
	#normalize to prevent faster diagonal movement
	if inputDir.length() > 0:
		inputDir = inputDir.normalized()
	
	var hasInput: bool = (inputDir != Vector3.ZERO)
	var changingDirection: bool = (inputDirSign != lastDirSign)
	var stopped: bool = (moveSpeed < 0.1)
	#set speed on ground
	if is_on_floor():
		if hasInput:
			if changingDirection:
				if !stopped:
					decelerate(delta)
					applyVelocity((transform.basis.z * lastDirSign).normalized())
				else:
					lastDirSign = inputDirSign
			else: # !changingDirection
				if moveSpeed < moveSpeedMax:
					accelerate(delta)
				applyVelocity(inputDir)
		else: # !hasInput
			# gets most recent direction, incl if player presses l/r with no fw/bw
			lastDir = (transform.basis.z * lastDirSign).normalized()
			if !stopped:
				decelerate(delta)
			applyVelocity(lastDir)

func accelerate(delta: float) -> void:
	moveSpeed += acceleration * delta

func decelerate(delta: float) -> void:
	moveSpeed -= deceleration * delta
	moveSpeed = max(0.0, moveSpeed)

func applyVelocity(dir: Vector3) -> void:
	velocity = dir * moveSpeed

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
