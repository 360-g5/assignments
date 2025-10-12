extends Node

class_name TerrainGenerator

# Exports for heightmap
@export_group("Heightmap Noise")
@export var height_seed: int = 654
@export var height_freq: float = 0.0158
@export var height_lacunarity: float = 0.5
@export var height_gain: float = 0.5

# Exports for texture
@export_group("Texture Noise")
@export var texture_seed: int = 654
@export var texture_freq: float = 0.2158  # adjusted, original A1 setting below
#@export var texture_freq: float = 0.0158
@export var texture_lacunarity: float = 2.5  # adjusted, original A1 setting below
#@export var texture_lacunarity: float = 0.5
@export var texture_gain: float = 22.5  # adjusted, original A1 setting below
#@export var texture_gain: float = 0.5

# Exported so you can tweak from the editor later
@export var grid_scale: float = 1.0
@export var height_scale: float = 40.0
@export var width: int = 502
@export var height: int = 502

var terrain: MeshInstance3D

# called from generate_mesh() and _make_noise_texture_2d()
func _make_noise(noise_seed: int, freq: float, lacuna: float, gain: float) -> FastNoiseLite:
	"""
	Creates noise image used for mesh and texture
	"""
	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM	 
	noise.fractal_octaves = 5
	noise.frequency = freq
	noise.fractal_lacunarity = lacuna
	noise.fractal_gain = gain
	noise.fractal_weighted_strength = 0.5
	return noise

# called from main.gd > _setup_scene()
func generate_mesh() -> MeshInstance3D:
	"""
	Returns a MeshInstance3D created from an image
	generated using exported heightmap settings
	"""
	var noise := _make_noise(height_seed, height_freq, height_lacunarity, height_gain)
	var img := noise.get_image(width, height)
	return _image_to_mesh(img)

# called from generate_mesh()
func _image_to_mesh(image: Image) -> MeshInstance3D:
	"""
	Converts image (ie heightmap) into MeshInstance3D
	value of a given pixel determines height of vertex at that point
	"""
	var w := image.get_width()
	var h := image.get_height()
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.index()

	# Vertices + UVs
	for y in range(h):
		for x in range(w):
			var height_v := image.get_pixel(x, y).r * height_scale
			var v := Vector3(x * grid_scale, height_v, y * grid_scale)
			var uv := Vector2(float(x) / float(w - 1), float(y) / float(h - 1))
			st.set_uv(uv)
			st.add_vertex(v)

	# Indices
	for y in range(h - 1):
		for x in range(w - 1):
			var i00 := y * w + x
			var i10 := i00 + 1
			var i01 := (y + 1) * w + x
			var i11 := i01 + 1

			st.add_index(i00); st.add_index(i10); st.add_index(i11)
			st.add_index(i00); st.add_index(i11); st.add_index(i01)

	st.generate_normals()

	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	return mi

# called from generate_texture()
func _make_noise_texture_2d() -> NoiseTexture2D:
	"""
	Creates the NoiseTexture2D to be used for the 
	StandardMaterial3D overlaid on the mesh
	"""
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = _make_noise(texture_seed, texture_freq, texture_lacunarity, texture_gain)
	await noise_texture.changed
	noise_texture.width = width
	noise_texture.height = height
	return noise_texture
	
# called from generate_texture()
func _noise_texture_2d_to_material(noise_texture: NoiseTexture2D) -> StandardMaterial3D:
	"""
	Creates StandardMaterial3D to be displayed on mesh from provided 
	NoiseTexture2D
	"""
	var material = StandardMaterial3D.new()
	material.albedo_texture = noise_texture
	return material
	
# called from main.gd > _setup_scene()
func generate_texture():
	"""
	Returns a StandardMaterial3D (made from NoiseTexture2D)
	to be used on mesh surface
	"""
	var noise_texture = await _make_noise_texture_2d()
	var material = _noise_texture_2d_to_material(noise_texture)
	return material
