# some debug meshes to draw spheres and lines at points when needed
# adapted from https://github.com/Ryan-Mirch/Line-and-Sphere-Drawing/tree/main
extends Node

func generate_point_sphere(pos:Vector3, radius = 1, colour = Color.AQUA) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos
	
	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = colour
	
	get_tree().get_root().add_child.call_deferred(mesh_instance)
	return mesh_instance


func generate_line_mesh(array: Array, colour = Color.DARK_ORCHID) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var line_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = line_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, material)
	for i in array:
		line_mesh.surface_add_vertex(i)
	line_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = colour
	
	get_tree().get_root().add_child.call_deferred(mesh_instance)
	return mesh_instance
