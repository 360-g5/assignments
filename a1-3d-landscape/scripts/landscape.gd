@tool  # runs this script in the editor so it is visible in 3D tab
extends Node3D

#load terrain generator
@onready var terrain_generator := TerrainGenerator.new()

func _ready():
	 #Terrain
	var terrain := terrain_generator.generate_mesh()
	var texture = await terrain_generator.generate_texture()
	terrain.set_surface_override_material(0, texture)
	addCollisionToTerrain(terrain)
	add_child(terrain)


func addCollisionToTerrain(terrain):
	#create a staticbody3D for collision
	var staticBody = StaticBody3D.new()
	terrain.add_child(staticBody)
	
	#create collision shape from the mesh
	var collisionShape = CollisionShape3D.new()
	staticBody.add_child(collisionShape)
	#generate collision shape from the track mesh
	var shape = terrain.mesh.create_trimesh_shape()
	collisionShape.shape = shape
