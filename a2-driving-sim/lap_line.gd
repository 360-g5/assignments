extends Area3D

# Signal emitted when a vehicle crosses the lap line
signal lap_completed(vehicle)

# Direction the vehicle should be moving to count as crossing
@export var forward_direction: Vector3 = Vector3.FORWARD

# Minimum speed threshold to count as crossing (optional)
@export var min_speed_threshold: float = 1.0

# Track which vehicles have recently crossed to prevent multiple triggers
var _recently_crossed: Dictionary = {}

func _ready():
	# Connect the area entered signal
	body_entered.connect(_on_body_entered)
	
	# Set up a timer to clear the recently_crossed cache
	var clear_timer = Timer.new()
	clear_timer.wait_time = 2.0  # Clear after 2 seconds
	clear_timer.timeout.connect(_clear_recently_crossed)
	add_child(clear_timer)
	clear_timer.start()

func _on_body_entered(body: Node3D):
	# Only process CharacterBody3D or vehicles
	if not body is CharacterBody3D:
		return
	
	# Check if this body recently crossed
	if _recently_crossed.has(body.get_rid()):
		return
	
func _get_velocity(body: Node3D) -> Vector3:
	if body is CharacterBody3D:
		return body.velocity
	elif "linear_velocity" in body:
		return body.linear_velocity
	return Vector3.ZERO

func _is_moving_forward(body: Node3D) -> bool:
	var velocity = _get_velocity(body)
	if velocity.length_squared() < 0.1:  # Almost stationary
		return false
	
	# Transform the forward direction to global space
	var global_forward = global_transform.basis * forward_direction.normalized()
	
	# Check if velocity is generally in the same direction
	return velocity.normalized().dot(global_forward) > 0.5

func _clear_recently_crossed():
	_recently_crossed.clear()
