@tool
extends Node2D

var timer = 0.0
var length = 2.0

# Called when the node enters the scene tree for the first time.
func _process(delta) -> void:
	timer += delta
	if timer > length:
		start_update()


func start_update() -> void:
	for child in get_children():
		for grandchild in child.get_children():
			grandchild.hide()
			if grandchild.name == "SkeletonSprite":
				grandchild.hide()
			if grandchild.name == "Sprite2D2":
				grandchild.show()
				child.sprite = grandchild
			if grandchild.name == "SkeletonSprite2":
				child.skeleton_sprite = grandchild
