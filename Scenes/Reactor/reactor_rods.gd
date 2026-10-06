@tool

extends MultiMeshInstance3D
class_name ReactorRodsMesh

@export_range(0.0, 50.0, 0.1) var diameter : float = 27.0:
	set(value):
		diameter = value
		_recalculate_mesh()
		
@export_range(0.1, 5.0, 0.1) var mesh_width = 0.6:
	set(value):
		mesh_width = value
		_recalculate_mesh()

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
		
	_recalculate_mesh()

func _recalculate_mesh() -> void:
	if not is_instance_valid(multimesh):
		return
		
	multimesh.instance_count = 0
	
	var row_length_in_meshes:int = floor(diameter / mesh_width) as int
	var real_row_length:float = row_length_in_meshes as float * mesh_width
	var x_pos:float = -real_row_length / 2.0
	var y_pos:float = x_pos

	var done:bool = false
	
	var x_count:int = 0
	var y_count:int = 0
	
	var transforms:Array[Transform3D]
	
	while !done:
		var centre_distance_squared:float = x_pos * x_pos + y_pos * y_pos
		if centre_distance_squared <= diameter * diameter / 4.0:		
			var mesh_pos = Transform3D.IDENTITY
			mesh_pos = mesh_pos.translated(Vector3(x_pos, 0.0, y_pos))
			transforms.push_back(mesh_pos)
		
		x_count += 1
		x_pos += mesh_width
		if x_count >= row_length_in_meshes:
			x_pos = -real_row_length / 2.0
			y_pos += mesh_width
			y_count += 1
			x_count = 0
			if y_count >= row_length_in_meshes:
				done = true
				
	multimesh.instance_count = transforms.size()
	for i in transforms.size():
		var trans = transforms[i]
		multimesh.set_instance_transform(i, trans)
		var angle = atan2(trans.origin.x, trans.origin.z)
		var dist = sqrt(trans.origin.x * trans.origin.x + trans.origin.z * trans.origin.z)
		multimesh.set_instance_custom_data(i, Color(trans.origin.x, trans.origin.z, angle, dist))
