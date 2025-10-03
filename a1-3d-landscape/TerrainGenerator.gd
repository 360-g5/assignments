extends Node

class_name TerrainGenerator

# Exported so you can tweak from the editor later
@export var grid_scale: float = 1.0
@export var height_scale: float = 40.0
@export var width: int = 502
@export var height: int = 502

func make_noise(seed: int = 654) -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.frequency = 0.0158
	noise.fractal_lacunarity = 0.5
	noise.fractal_gain = 0.5
	noise.fractal_weighted_strength = 0.5
	return noise


func generate() -> MeshInstance3D:
	var noise := make_noise()
	var img := noise.get_image(width, height)
	return _image_to_mesh(img)


func _image_to_mesh(image: Image) -> MeshInstance3D:
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
