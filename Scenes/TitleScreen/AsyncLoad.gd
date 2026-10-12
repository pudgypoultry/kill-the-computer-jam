extends CanvasLayer

@export var progress_bar: ProgressBar
@export var next_scene_path: String = ""
var progress: Array = []

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene_path)

func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				progress_bar.value = progress[0] * 100.0
		ResourceLoader.THREAD_LOAD_LOADED:
			var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
			get_tree().change_scene_to_packed(packed_scene)
		ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Failed to load scene: " + next_scene_path)
			set_process(false)
