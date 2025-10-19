# handles setting up the track now instead of old method in now-deleted path_3d.gd
# so that everything works with adapted w4 example spline generation
# the base track points are now made w array of Vector3s, similar to P (array of Vector2s)
# in the sample Splines project

extends Node3D

# adjust to make track wider/narrower
@export var track_width: float = 20.0
# adjust to make curves more/less stiff; 0.5 = catmull-rom spline
@export var track_tension: float = 0.5
# adjust to add more/less interpolated pts per spline
@export var spline_resolution: int = 10

@onready var path: Path3D = $Path3D
@onready var track_mesh: MeshInstance3D = $TrackMesh

func _ready():
	generate_track()
	pass

func generate_track():
	var control_points = get_control_points()
	
	# where the magic happens
	# thank you Russell and Freya
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
	

func get_control_points() -> Array:
	# square tester track
	#var base = [
		#Vector3(0, 50, 0),
		#Vector3(100, 50, 0),
		#Vector3(100, 50, 100),
		#Vector3(0, 50, 100)
	#]
	
	# this is also a tester track, just bigger
	var base = [
		Vector3(50, 50, 50),
		Vector3(100, 50, 150),
		Vector3(190, 50, 160),
		Vector3(270, 50, 100),
		Vector3(200, 50, 60)
	]
	
	var wrapped = wrap_for_closed_loop(base)
	
	#print("Base points: ", base.size())
	#print("Wrapped points: ", wrapped.size())
	#print("Segments to generate: ", wrapped.size() - 3)  
	
	return wrapped


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
