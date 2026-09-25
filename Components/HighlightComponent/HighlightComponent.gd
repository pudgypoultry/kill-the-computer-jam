extends Node
class_name HighlightComponent

@export var highlight_material : ShaderMaterial

var actor_reference : Node3D
var actor_mesh : MeshInstance3D

func _ready():
	actor_reference = get_parent()
	actor_mesh = actor_reference.find_children("*", "MeshInstance3D")[0]
	actor_reference.connect("mouse_entered", apply_highlight)
	actor_reference.connect("mouse_exited", remove_highlight)


func apply_highlight():
	# print(actor_mesh.get_active_material(0))
	actor_mesh.get_active_material(0).next_pass = highlight_material


func remove_highlight():
	actor_mesh.get_active_material(0).next_pass = null
