# adapted from cardinal spline generation in Splines project supplied in Week 4
# additional references:
# Russell Campbell Week 4 Splines lecture pdf 
# Freya Holmér-The Continuity of Splines https://www.youtube.com/watch?v=jvPPXbo87ds
class_name Spline
extends Object

# static so that it doesn't need to be instantiated to be used
# most of this spline() is copied directly from spline() in the example project
static func spline(res: int, s: float, control_points: Array) -> Array:
	"""
	Generates a Cardinal spline based on an array of 4 control_points
		res: resolution, ie how many interpolated pts in the segment
		s: velocity scale, aka tension, ie how stiff/relaxed the curves should be
			s = 0.5 makes it a Catmull-Rom spline
	"""
	var pts = []
	
	for k in range(res + 1):
		var t = float(k) / res
		var PolyT = Matrix.new(1, 4)
		PolyT.set_data([[ 1, t, t*t, t*t*t ]])
		
		var CharMtx = Matrix.new(4, 4)
		CharMtx.set_data([
			[0,    1,     0,      0],
			[-s,   0,     s,      0],
			[2*s,  s-3,   3-2*s, -s],
			[-s,   2-s,   s-2,    s]
		])
		
		# this part is needed since Matrix.mulitpy() accepts floats and Vector2s.
		# Vector3s use float coordinates: https://docs.godotengine.org/en/stable/classes/class_vector3.html
		# so by getting the coords individually, we can use matrix.gd without modifying
		var x = _spline_coordinate(PolyT, CharMtx, [control_points[0].x, control_points[1].x, control_points[2].x, control_points[3].x])
		var y = _spline_coordinate(PolyT, CharMtx, [control_points[0].y, control_points[1].y, control_points[2].y, control_points[3].y])
		var z = _spline_coordinate(PolyT, CharMtx, [control_points[0].z, control_points[1].z, control_points[2].z, control_points[3].z])
		
		pts.append(Vector3(x, y, z))
	
	return pts

# the last part of example project spline() but PtMtx.set_data is passed 
# individual float coords instead of PP (an array of Vector2s)
static func _spline_coordinate(PolyT: Matrix, CharMtx: Matrix, coords: Array) -> float:
	var PtMtx = Matrix.new(4, 1)
	PtMtx.set_data([[coords[0]], [coords[1]], [coords[2]], [coords[3]]])
	return PolyT.multiply(CharMtx).multiply(PtMtx).get_value(0, 0)

# uses central logic from example project spline_example()
static func generate_full_spline(control_points: Array, res: int, s: float) -> Array:
	"""
	Generates a complete spline through all control points by splitting
	them into groups of 4 at a time for spline(), then joins the splined
	points together in all_points array
	"""
	var all_points = []
	
	# size() - 3 is bc every segment needs 4 control pts
	# so the last place to start a 4pt segment from is index k-4
	for k in range(control_points.size() - 3):
		var segment = [
			control_points[k],     # P0 
			control_points[k + 1], # P1 
			control_points[k + 2], # P2
			control_points[k + 3]  # P4
		]
		
		var segment_points = spline(res, s, segment)
		
		# segment 1 ends on the pt where segment 2 starts, etc, so after the 
		# first segment, skip the first point so we don't get duplicates
		var start_idx = 0 if k == 0 else 1
		for j in range(start_idx, segment_points.size()):
			all_points.append(segment_points[j])
	
	return all_points
