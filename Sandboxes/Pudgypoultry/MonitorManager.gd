extends Node3D
class_name MonitorManager

@export var switched_faceplate : Sprite3D
@export var audio_player : AudioStreamPlayer3D
@export var switch_single_sfx : AudioStreamWAV
@export var switch_double_sfx : AudioStreamWAV
@export var slots : Array[CardSlot]
@export var screen_2 : Sprite3D
@export var song_1 : AudioStreamOggVorbis
@export var song_2 : AudioStreamOggVorbis
@export var song_3 : AudioStreamOggVorbis

@onready var toggle_left_highlight: Sprite3D = %ToggleLeftHighlight
@onready var toggle_right_highlight: Sprite3D = %ToggleRightHighlight
@onready var music_player : AudioStreamPlayer3D = %MusicPlayer

var switch_flipped : bool = false
var debug_timer = 0.0
var debug_interval = 1.0

var _should_show_left_highlight:bool = false
var _should_show_right_highlight:bool = false

var is_focused:bool = false:
	set(value):
		if value == is_focused:
			return
			
		is_focused = value
		
		_update_highlight_state()
			

func _ready() -> void:
	BoardManager.terminal_screen = screen_2
	BoardManager.player_control_changed.connect(_on_player_control_changed)

func _process(_delta : float):
	var mouse_cursor = MouseCursor.get_global_cursor()
	if BoardManager.current_focus == self && Input.is_action_just_pressed("interact"):
		flip_switch()
		mouse_cursor.add_grab_target(self)
	elif Input.is_action_just_released("interact") and mouse_cursor.has_grab_target(self):
		mouse_cursor.remove_grab_target(self)


func flip_switch():
	if BoardManager.player_actionable:
		if switch_flipped:
			for slot in slots:
				if slot.has_card():
					slot.eject_card()
			switch_flipped = false
			switched_faceplate.hide()
			play_sfx(switch_single_sfx)
			for slot in slots:
				slot.single_mode = true
		else:
			switch_flipped = true
			switched_faceplate.show()
			play_sfx(switch_double_sfx)
			for slot in slots:
				slot.single_mode = false
				
		_update_highlight_state()


func play_sfx(sfx : AudioStreamWAV):
	audio_player.stream = sfx
	audio_player.play()


func check_slots() -> int:
	var num_cards = 0
	for slot in slots:
		if slot.current_card != null:
			num_cards += 1
	return num_cards


func _on_mouse_entered() -> void:
	is_focused = true


func _on_mouse_exited() -> void:
	is_focused = false


func _update_highlight_state() -> void:
	var mouse_cursor = MouseCursor.get_global_cursor()
	if is_focused and (not mouse_cursor.is_grabbing() or mouse_cursor.has_grab_target(self)):
		if switch_flipped:
			_should_show_left_highlight = false
			_should_show_right_highlight = true
		else:
			_should_show_left_highlight = true
			_should_show_right_highlight = false
	else:
		_should_show_left_highlight = false
		_should_show_right_highlight = false
		
	_update_highlight_visuals()

func _update_highlight_visuals() -> void:
	var mouse_cursor = MouseCursor.get_global_cursor()
	
	toggle_left_highlight.visible = _should_show_left_highlight if BoardManager.player_actionable else false
	toggle_right_highlight.visible = _should_show_right_highlight if BoardManager.player_actionable else false
	
	var is_highlighted:bool = toggle_left_highlight.visible or toggle_right_highlight.visible

	if is_highlighted:	
		BoardManager.current_focus = self
		if not mouse_cursor.has_highlight_target(self):
			mouse_cursor.add_highlight_target(self)
	else:
		if mouse_cursor.has_highlight_target(self):
			mouse_cursor.remove_highlight_target(self)

func _on_player_control_changed(_value:bool) -> void:
	_update_highlight_visuals()
