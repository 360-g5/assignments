extends Area3D

@export var boost_forward: float = 20.0   # strength of the push forward
@export var boost_up: float = 6.0         # strength of the upward push
@export var cooldown_sec: float = 0.3     # small delay between boosts

var _cooling_down := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if _cooling_down:
		return

	var dir := global_transform.basis.z.normalized()
	var impulse := dir * boost_forward + Vector3.UP * boost_up

	if body is RigidBody3D:
		body.apply_impulse(impulse)
		_start_cooldown()
	elif body is CharacterBody3D:
		body.velocity += impulse
		_start_cooldown()

func _start_cooldown():
	_cooling_down = true
	await get_tree().create_timer(cooldown_sec).timeout
	_cooling_down = false
