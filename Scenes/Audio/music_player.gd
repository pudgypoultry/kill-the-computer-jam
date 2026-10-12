extends AudioStreamPlayer
class_name MusicPlayer

enum MusicTrack
{
	NONE,
	AMBIENCE,
	LOW_INTENSITY,
	HIGH_INTENSITY
}

@export var music_table:Dictionary[MusicTrack, String] = {
	MusicTrack.AMBIENCE: "ambience",
	MusicTrack.LOW_INTENSITY: "music_low",
	MusicTrack.HIGH_INTENSITY: "music_high"
}

var _current_music:MusicTrack = MusicTrack.AMBIENCE

static var _global_music_player : MusicPlayer

static func get_global_music_player() -> MusicPlayer:
	return _global_music_player

func _ready() -> void:
	_global_music_player = self

func change_music(music_track:MusicTrack) -> void:
	# This is obviously very "this game"-specific but music only escalates in one direction
	# and can't be paused or stopped
	if music_track == MusicTrack.NONE or music_track <= _current_music:
		return
	
	var interactive_playback = get_stream_playback() as AudioStreamPlaybackInteractive
	if not is_instance_valid(interactive_playback):
		push_error("Music stream is missing or incorrect type. Expected AudioStreamInteractive.")
		return
		
	if not music_table.has(music_track):
		push_error("Missing music table entry for track " + str(music_track))
		return
	
	_current_music = music_track	
	interactive_playback.switch_to_clip_by_name(music_table[music_track])
