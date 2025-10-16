# Godot Docs for ArrayMesh https://docs.godotengine.org/en/stable/tutorials/3d/procedural_geometry/arraymesh.html
# Freya Holmér-The Continuity of Splines https://www.youtube.com/watch?v=jvPPXbo87ds
# Freya Holmér-Unite 2015: A coder's guide to spline-based procedural generation https://www.youtube.com/watch?v=o9RK6O2kOKo

extends MeshInstance3D

@onready var path := get_node("/root/World/Path3D")
@onready var debug := get_node("/root/World/Node3D")

func _ready():
	draw_track()
	
func get_tangent_at_offset(curve: Curve3D, offset: float) -> Vector3:
	var delta = 0.01
	
	var pointA = curve.sample_baked(offset)
	var pointB = curve.sample_baked(offset+delta)
	
	var tangent = (pointB - pointA).normalized()
	return tangent
	
func draw_track():
	mesh.clear_surfaces()
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()
	
	
	#####
	# mesh generation
	######
	
	# Vertex indices.
	var prev_left = 0
	var prev_right = 0
	var current_left = 1
	var current_right = 1
	
	# set trackwidth and dist from centre pt to edge of track
	var track_width : float = 20
	var track_half_width : float = track_width / 2
	
	# get sample points from curve drawn in path_3d.gd
	# "baking" is how curve3Ds do bezier splines:
	# https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html
	# but the path still isn't curved so I'm missing something haha
	path.curve.set_bake_interval(1)
	var number_of_samples = 200
	var total_length = path.curve.get_baked_length()
	var sample_distance = total_length / number_of_samples
	
	for i in range(number_of_samples):
		var distance = i * sample_distance
		var sample_position = path.curve.sample_baked(distance)
		#print("sample position: ", sample_position)
		#debug.generate_point_sphere(sample_position)
	
		var tangent = get_tangent_at_offset(path.curve, distance)
		#print("tangent: ", tangent)
		
		# get vector perpindicular to tangent and UP
		# if we do angled tracks then UP needs to become a specific up 
		# but this is fine for flat track
		var right = tangent.cross(Vector3.UP).normalized()
		#print("right: ", right)
		
		# get left and right vertices of track from the 
		# point on the curve
		var left_vert = sample_position - (right * track_half_width)
		var right_vert = sample_position + (right * track_half_width)
	
		# the order of this is important
		# always left first, then right
		debug.generate_point_sphere(left_vert)
		debug.generate_point_sphere(right_vert)
		
		verts.append(left_vert)
		verts.append(right_vert)
		normals.append(Vector3.UP)
		normals.append(Vector3.UP)
		
		# UVs are for mapping where the textures connect to
		# we'll use a texture that repeats on each quad
		# it's going to look weird when the points are closer 
		# together but I'm trying to get a MVP rn
		#
		# point 0:  0,0 -- 1,0
		#           |       |
		# point 1:  0,1 -- 1,1
		#
		var v : float = i % 2  
		# first uv is for the left vertex
		uvs.append(Vector2(0.0, v))
		uvs.append(Vector2(1.0, v))
		
		# then for triangle index generation
		# basically you're making a bunch of rectangles (quads)
		# that get cut diagonally into 2 triangles
		# like 
		# point 0:  L0 -- R0
		#           |   /  |
		# point 1:  L1 -- R1
		#           |   /  |
		# point 2:  L2 -- R2
		#
		# each triangle has 3 indices 
		# so each quad has 6 indices
		#
		# since we are going left, then right for the vertex order
		# verts[0] = L0
		# verts[1] = R0
		# etc
		#
		# Godot uses clockwise winding order
		# for primitive triangle front faces
		if i > 0:
			prev_left = (i - 1) * 2  # times 2 bc there is 2 verts per sample pt
			prev_right = (i - 1) * 2 + 1
			current_left = i * 2
			current_right = i * 2 + 1
			
			# triangle 1
			indices.append(current_left)
			indices.append(prev_right)
			indices.append(prev_left)
			
			#triangle 2
			indices.append(current_left)
			indices.append(current_right)
			indices.append(prev_right)
			
	# close the loop with last triangle
	var last_left = (number_of_samples - 1) * 2
	var last_right = (number_of_samples - 1) * 2 + 1
	var first_left = 0
	var first_right = 1
	
	indices.append(first_left)
	indices.append(last_right)
	indices.append(last_left)
	
	indices.append(first_left)
	indices.append(first_right)
	indices.append(last_right)
	
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	#print("total vertices: ", verts.size())
	#print("total uvs: ", uvs.size())
	#print("total normals: ", normals.size())
	#print("total indices: ", indices.size())
	
	
	## Print first quad's indices
	#print("First quad indices:")
	#print("Triangle 1: ", indices[0], indices[1], indices[2])
	#print("Triangle 2: ", indices[3], indices[4], indices[5])

	
	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	

	var material = StandardMaterial3D.new()
	# un-comment this to see full mesh without culling of back faces of triangles
	#material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color.FOREST_GREEN
	set_surface_override_material(0, material)
