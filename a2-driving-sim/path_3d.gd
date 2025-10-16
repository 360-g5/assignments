# where I'm making the curve that draws the track
# not sure if this is the best way to do it but it works for now
@tool
extends Path3D

@onready var track_curve = curve
var lines : Array

func _ready():
	#add_points_to_curve()
	pass
	
func add_points_to_curve():
	track_curve.clear_points()
	
	track_curve.add_point(Vector3(50, 50, 50))
	
	# smaller track
	#track_curve.add_point(Vector3(100, 50, 50))
	#track_curve.add_point(Vector3(100, 50, 100))
	#track_curve.add_point(Vector3(50, 50, 100))
	
	# larger track
	track_curve.add_point(Vector3(100, 50, 150))
	track_curve.add_point(Vector3(190, 50, 160))
	track_curve.add_point(Vector3(270, 50, 100))
	track_curve.add_point(Vector3(200, 50, 60))
	
	# sets resolution, default is 0.2, smaller is smoother
	#track_curve.closed = true
	#track_curve.set_bake_interval(10)
	
	# total curve length after baking
	#var curve_len = track_curve.get_baked_length()
	#print(curve_len)
	
	# returns a Vector3 at that distance (in m) along the cuve
	#var baked_samp = track_curve.sample_baked(2.5)
	#print(baked_samp)
	
	
