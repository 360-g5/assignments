@tool  # runs this script in the editor so it is visible in 3D tab
extends Node3D

#load camera for method
const CameraController = preload("res://cameraController.gd")

func _ready():
	# Camera
	add_child(make_camera(Vector3(264, 60, 460), Vector3(64, 60, 64)))
	# Lighting
	add_child(make_sun())
#
func make_camera(pos: Vector3, target: Vector3) -> Camera3D:
	var camera := Camera3D.new()
	#attach camera to script
	camera.set_script(CameraController) 
	camera.position = pos
	camera.look_at_from_position(pos, target, Vector3.UP)
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
