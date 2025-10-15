@tool  # runs this script in the editor so it is visible in 3D tab
extends Node3D

#load terrain generator
@onready var terrain_generator := TerrainGenerator.new()

func _ready():
	 #Terrain
	var terrain := terrain_generator.generate_mesh()
	var texture = await terrain_generator.generate_texture()
	terrain.set_surface_override_material(0, texture)
	add_child(terrain)
