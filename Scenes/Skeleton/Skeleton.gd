extends Node3D
class_name Skeleton

@export var talk_message : Array[String] = [""]
@export var zoom_node : Node3D

@onready var skeleton_audio: AudioStreamPlayer3D = %SkeletonAudio

var zoom_position : Vector3 = Vector3.ZERO

func _ready() -> void:
	zoom_position = zoom_node.global_position

func play_speech_audio() -> void:
	skeleton_audio.play()
