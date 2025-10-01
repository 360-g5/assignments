extends Node3D

func _ready():
	var noise := FastNoiseLite.new()
	noise.seed = 654
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5 # from sunny branch
	#noise.fractal_octaves = 4
	noise.frequency = 0.0158  # from sunny branch
	#noise.frequency = 0.006
	noise.fractal_lacunarity = 0.5  # from sunny branch
	#noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	noise.fractal_weighted_strength = 0.5  # from sunny branch
	#noise.fractal_weighted_strength = 0.2

	var img_noise := noise.get_image(502, 502)  # from sunny branch
	#var img_noise := noise.get_image(128, 128)  # start small for speed

	var terrain := noiseToLandscape(img_noise, 1.0, 40.0)
	add_child(terrain)

	var camera := Camera3D.new()
	camera.position = Vector3(264, 60, 460)  # adjusted by Sho so it starts in a nicer spot
	#camera.position = Vector3(64, 80, 160)
	camera.look_at(Vector3(64, 0, 64), Vector3.UP)
	camera.current = true  # ensure this camera is active
	add_child(camera)

	# original lighting
	#var light := DirectionalLight3D.new()
	#light.rotation_degrees = Vector3(-45, -30, 0)
	#add_child(light)
	
	# lighting from sunny
	# --- Main Sun Light ---
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.5
	sun.light_color = Color(1.0, 0.9, 0.7)
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	sun.shadow_normal_bias = 1.0
	sun.rotation_degrees = Vector3(-45, -30, 0) # angle for nice dune shadows
	add_child(sun)


func noiseToLandscape(image: Image, gridScale: float, heightScale: float) -> MeshInstance3D:
	var w := image.get_width()
	var h := image.get_height()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.index()  # reuse vertices

# Create shared vertices with UVs
	for y in range(h):
		for x in range(w):
			var height_v := image.get_pixel(x, y).r * heightScale
			var v := Vector3(x * gridScale, height_v, y * gridScale)
			var uv := Vector2(float(x) / float(w - 1), float(y) / float(h - 1))
			st.set_uv(uv)
			st.add_vertex(v)

	# Add indices (two triangles per cell)
	for y in range(h - 1):
		for x in range(w - 1):
			var i00 := y * w + x
			var i10 := y * w + (x + 1)
			var i01 := (y + 1) * w + x
			var i11 := (y + 1) * w + (x + 1)

			st.add_index(i00)
			st.add_index(i10)
			st.add_index(i11)
			st.add_index(i00)
			st.add_index(i11)
			st.add_index(i01)

	# Generate smooth normals so dunes shade smoothly
	st.generate_normals()

	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	return mi
