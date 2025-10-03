extends Node3D
@onready var terrain_generator := TerrainGenerator.new()

func _ready():
	# Terrain
	var terrain := terrain_generator.generate_mesh()
	var texture = await terrain_generator.generate_texture()
	terrain.set_surface_override_material(0, texture)
	add_child(terrain)

	# Camera
	add_child(make_camera(Vector3(264, 60, 460), Vector3(64, 0, 64)))

	# Lighting
	add_child(make_sun())


func make_camera(pos: Vector3, target: Vector3) -> Camera3D:
	var camera := Camera3D.new()
	camera.position = pos
	camera.look_at(target, Vector3.UP)
	camera.current = true
	return camera


func make_sun() -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.8, 0.5)
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.0
	sun.rotation_degrees = Vector3(-45, -30, 0)
	return sun
