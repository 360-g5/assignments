# handles setting up the track now instead of old method in now-deleted path_3d.gd
# so that everything works with adapted w4 example spline generation
# the base track points are now made w array of Vector3s, similar to P (array of Vector2s)
# in the sample Splines project

extends Node3D

# adjust to make track wider/narrower
@export var track_width: float = 23.0
# adjust to make curves more/less stiff; 0.5 = catmull-rom spline
@export var track_tension: float = 0.5
# adjust to add more/less interpolated pts per spline
@export var spline_resolution: int = 30
# now sets y for base points and hilbert points
@export var track_y_level: float = 50.0

@export var lap_line_scene: PackedScene

@export_category("Hilbert")
# hilbert curve is now rotated around a center point specified here
@export var hilbert_center_x: float = 280.0
@export var hilbert_center_z: float = 130.0
@export var hilbert_rotation: float = 270.0
@export var hilbert_size: float = 230.0
@export var hilbert_reverse: bool = false

@onready var path: Path3D = $Path3D
@onready var track_mesh: MeshInstance3D = $TrackMesh
#@onready var debug := get_node("/root/World/Debug")

func _ready():
	generate_track()
	pass

func generate_track():
	var control_points = get_control_points()
	
	var splined_points = Spline.generate_full_spline(
		control_points, 
		spline_resolution, 
		track_tension
	)
	
	path.curve.clear_points()
	for point in splined_points:
		path.curve.add_point(point)
	
	track_mesh.generate_from_curve(path.curve, track_width)
	addCollisionToTrack()
	position_lap_line()

func get_control_points() -> Array:
	var base = [
		Vector3(80, track_y_level, 50),   # 0
		Vector3(250, track_y_level, 90),  # 1
		Vector3(400, track_y_level, 70), # 2
		Vector3(450, track_y_level, 160), # 3
		Vector3(430, track_y_level, 350), # 4
		Vector3(350, track_y_level, 440), # 5
		Vector3(250, track_y_level, 410), # 6
		Vector3(70, track_y_level, 400), # 7
		Vector3(100, track_y_level, 250), # 8
		Vector3(50, track_y_level, 150), # 9
	]
	
	#for i in base.size():
		#debug.generate_point_sphere(base[i])
	
	# splice a Hilbert detour between two points in base
	var A := 3  # entrance index in base
	var B := 4  # exit index in base
	var H: Array[Vector2] = hilbert_points(2)  # L2

	# Builds the Hilbert curve section that connects the two points on the track at height 50
	var detour: Array[Vector3] = fit_hilbert_between(
		H, 
		Vector3(hilbert_center_x, track_y_level, hilbert_center_z), 
		hilbert_size, 
		hilbert_reverse,
		hilbert_rotation, 
		)
	
	# drop endpoints (they equal entrance/exit) so we don't duplicate
	var detour_interior := detour.slice(1, detour.size() - 1)

	# Combine the main track and detour points into a single path before closing the loop
	var stitched: Array[Vector3] = []
	stitched.append_array(base.slice(0, A + 1))
	stitched.append_array(detour_interior)
	stitched.append_array(base.slice(B, base.size()))

	var wrapped = wrap_for_closed_loop(stitched)
	
	return wrapped

func position_lap_line():
	# Remove existing lap line if any
	var existing_lap_line = get_node_or_null("LapLine")
	if existing_lap_line:
		existing_lap_line.queue_free()
	
	# Create lap line completely programmatically
	var lap_line = Area3D.new()
	lap_line.name = "LapLine"
	add_child(lap_line)
	
	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(track_width * 1.5, 4.0, 2.0)
	collision_shape.shape = box_shape
	lap_line.add_child(collision_shape)
	
	# Add visual mesh for debugging
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(track_width * 1.5, 4.0, 2.0)
	mesh_instance.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0, 0.3)  # Red with transparency
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.set_surface_override_material(0, material)
	lap_line.add_child(mesh_instance)
	
	# Position at track start
	var start_position = path.curve.get_point_position(0)
	lap_line.global_position = start_position + Vector3(0, 2, 0)
	
	# Rotate to align with track direction
	var track_direction = path.curve.get_point_position(1) - path.curve.get_point_position(0)
	track_direction = track_direction.normalized()
	lap_line.look_at(lap_line.global_position + track_direction, Vector3.UP)
	
	# Add the lap line script functionality
	lap_line.body_entered.connect(_on_lap_line_body_entered)
	
	#print("Lap line created and positioned at: ", lap_line.global_position)

func _on_lap_line_body_entered(body: Node3D):
	if body is CharacterBody3D:
		print("Lap completed by: ", body.name)
		if has_node("/root/RaceManager"):
			get_node("/root/RaceManager").add_lap()
			
func _adjust_lap_line_collision(lap_line: Node3D):
	var collision_shape = lap_line.get_node_or_null("CollisionShape3D")
	if not collision_shape:
		push_warning("No CollisionShape3D found in lap line")
		return
	
	# Make collision shape wide enough to span the track
	if collision_shape.shape is BoxShape3D:
		var box_shape: BoxShape3D = collision_shape.shape
		box_shape.size = Vector3(track_width * 1.5, 4.0, 2.0)  # Wide, tall, thin
	elif collision_shape.shape is CylinderShape3D:
		var cylinder_shape: CylinderShape3D = collision_shape.shape
		cylinder_shape.height = track_width * 1.5
		cylinder_shape.radius = 1.0

func _on_lap_completed():
	print("Lap completed signal received in TrackManager")
	RaceManager.add_lap()

# (not needed in example project since that spline was not closed)
# since splines are done in chunks of 4 pts, you need k+3 pts
# to have the last chunk that connects the end to the beginning
func wrap_for_closed_loop(base_points: Array) -> Array:
	"""
	Adds in the 3 pts necessary to give each base point a segment,
	closing the spline loop
	"""
	var wrapped = []
	var k = base_points.size()
	
	# get last point so it can connect to first pt
	wrapped.append(base_points[k - 1])
	
	# then add in the points 0-k
	for point in base_points:
		wrapped.append(point)
	
	# get first and second points again
	wrapped.append(base_points[0])
	wrapped.append(base_points[1])
	
	return wrapped

#Hilbert helpers

# Generate 2D Hilbert curve points within a 0–1 range
func hilbert_points(order: int) -> Array[Vector2]:
	var n := 1 << order
	var out: Array[Vector2] = []
	out.resize(n * n)
	for d in range(n * n):
		var xy := _hilbert_d2xy(n, d)
		out[d] = Vector2(xy.x / float(n - 1), xy.y / float(n - 1))
	return out

# Convert a single Hilbert index (d) into a 2D grid coordinate (x, y)
func _hilbert_d2xy(n: int, d: int) -> Vector2i:
	var t := d
	var x := 0
	var y := 0
	var s := 1
	while s < n:
		var rx := 1 & int(t / 2)
		var ry := 1 & int(t ^ rx)
		var v := _hilbert_rot(s, x, y, rx, ry)
		x = v.x
		y = v.y
		x += s * rx
		y += s * ry
		t = int(t / 4)
		s *= 2
	return Vector2i(x, y)
# Rotate and flip the coordinate system based on Hilbert curve quadrant
func _hilbert_rot(n: int, x: int, y: int, rx: int, ry: int) -> Vector2i:
	if ry == 0:
		if rx == 1:
			x = n - 1 - x
			y = n - 1 - y
		var tmp := x
		x = y
		y = tmp
	return Vector2i(x, y)

# Generate a Hilbert curve centered at the given position with size, rotation, and optional flip
func fit_hilbert_between(
	h2d: Array[Vector2], 
	center: Vector3,
	size: float, 
	# set true to flip the curve direction (useful if base path is counter-clockwise)
	reverse_dir: bool, 
	rotation_deg: float = 0.0,
	) -> Array[Vector3]:
	
	var yaw := deg_to_rad(rotation_deg)
	var rot := Basis(Vector3.UP, yaw)

	var out: Array[Vector3] = []
	out.resize(h2d.size())
	for i in range(h2d.size()):
		var p := h2d[i]  # 0..1
		var local := Vector3(p.x * size, 0.0, (p.y - 0.5) * size)
		var world := center + rot * local
		world.y = center.y
		out[i] = world

	if reverse_dir:
		out.reverse()
	
	return out

func addCollisionToTrack():
	#create a staticbody3D for collision
	var staticBody = StaticBody3D.new()
	track_mesh.add_child(staticBody)
	#create collision shape from the mesh
	var collisionShape = CollisionShape3D.new()
	staticBody.add_child(collisionShape)
	#generate collision shape from the track mesh
	var shape = track_mesh.mesh.create_trimesh_shape()
	collisionShape.shape = shape
	
