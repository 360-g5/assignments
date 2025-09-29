extends Node3D

func _ready():
	# --- Main Sun Light ---
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.5
	sun.light_color = Color(1.0, 0.9, 0.7)
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.0
	sun.rotation_degrees = Vector3(-45, -30, 0) # angle for nice dune shadows
	add_child(sun)
