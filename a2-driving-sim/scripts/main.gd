@tool  # runs this script in the editor so it is visible in 3D tab
extends Node3D

#load camera for method
const PlayerController = preload("res://scripts/playerController.gd")
const SmokeGenerator = preload("res://scripts/smokeGenerator.gd")

func _ready():
	add_child(makePlayerBody(Vector3(80, 60, 50), Vector3(250, 50, 90)))
	# Lighting
	add_child(make_sun())
#


#makes smoke a node that follows camera
func makeSmoke(camera):
	var smoke := Node3D.new()
	smoke.set_script(SmokeGenerator)
	camera.add_child(smoke)

#adds car wheel as a sprite that rotates
func makeCar(camera):
	var wheel := Sprite3D.new()
	wheel.name = "wheel"
	wheel.texture = load("res://images/wheel.png")
	wheel.billboard = BaseMaterial3D.BILLBOARD_DISABLED 
	wheel.position = Vector3(0, -0.65, -0.8) 
	wheel.scale = Vector3(0.2, 0.2, 0.2)
	#create material so doesnt affect smoke
	var material := StandardMaterial3D.new()
	#render on top of smoke
	material.no_depth_test = true
	#ignore lighting 
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	#apply texture
	material.albedo_texture = wheel.texture
	#transparent bg
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wheel.material_override = material
	camera.add_child(wheel)

func makePlayerBody(pos: Vector3, target: Vector3):
	var player := CharacterBody3D.new()
	player.set_script(PlayerController)
	player.position = pos
	player.look_at_from_position(pos, target, Vector3.UP)
	
	
	#add collision to player
	var collisionShape = CollisionShape3D.new()
	var capsule = CapsuleShape3D.new()
	capsule.radius = 1.0
	capsule.height = 2.0
	collisionShape.shape = capsule
	player.add_child(collisionShape)

	#add a camera as a child 
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	#make cam a bit above
	camera.position = Vector3(0, 2, 0)
	player.add_child(camera)

	#add smoke as child
	var smoke := Node3D.new()
	smoke.set_script(SmokeGenerator)
	player.add_child(smoke)
	
	#add car parts
	makeCar(camera)

	return player	
	
	

func make_sun() -> DirectionalLight3D:
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.1
	sun.light_color = Color(1.0, 0.8, 0.5)
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.0
	sun.rotation_degrees = Vector3(-45, -30, 0)
	return sun
