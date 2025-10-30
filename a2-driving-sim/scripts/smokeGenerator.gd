#https://docs.godotengine.org/en/stable/classes/class_gpuparticles3d.html
#https://docs.godotengine.org/en/stable/classes/class_particleprocessmaterial.html

extends Node3D

#vars for smoke path and colour
@export var texturePath: String = "res://images/smoke.png"
@export var smoke_color: Color = Color(0.8, 0.8, 0.8, 0.9)


#call when instantiated
func _ready():
	create_smoke()

#using gpu particles create smoke that follows the camera
func create_smoke():
	var smoke = GPUParticles3D.new()
	smoke.amount = 400
	smoke.lifetime = 8.0
	smoke.preprocess = 8.0
	smoke.one_shot = false
	smoke.explosiveness = 0.0
	smoke.local_coords = false
	#culling factor
	smoke.visibility_aabb = AABB(Vector3(-20, -20, -20), Vector3(40, 40, 40))


	#create quad mesh for particle
	var quad = QuadMesh.new()
	quad.size = Vector2(5, 5)

	#create material for particles
	var material = StandardMaterial3D.new()
	material.albedo_texture = load(texturePath)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	#face camera alwayts
	material.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	material.albedo_color = smoke_color
	#ignore shading
	material.flags_unshaded = true
	quad.material = material
	smoke.draw_pass_1 = quad

	#particle behavuours
	var mat = ParticleProcessMaterial.new()
	mat.color = Color(0.8, 0.7, 0.55, 0.1)
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 1.5
	mat.initial_velocity_max = 3.5
	mat.spread = 105.0
	smoke.process_material = mat

	
	smoke.position = Vector3(0, -2, 6)
	add_child(smoke)
