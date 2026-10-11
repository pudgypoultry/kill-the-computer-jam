extends MarginContainer
class_name TerminalManager

@onready var text_beeps: AudioStreamPlayer = %TextBeeps

@export var text_interval = 0.0
@export var text_timer = 0.0
@export var blink_delay = 0.5

@export var non_term_punctuation_interval = 0.125
@export var period_interval = 0.25

@export var label : RichTextLabel

var writing : bool = false
var blink_timer:float = blink_delay
var current_message : String = ">"

func _ready() -> void:
	BoardManager.terminal_manager = self
	label.visible_characters = 0

func _process(delta: float) -> void:
	if writing:
		text_timer += delta
		
		var interval_to_use:float = 0.0
		var last_printed_char:String = label.text[label.visible_characters - 1] if label.visible_characters > 0 else ""
		match(last_printed_char):
			".":
				interval_to_use = period_interval
			",":
				interval_to_use = non_term_punctuation_interval
			";":
				interval_to_use = non_term_punctuation_interval
			"—":
				interval_to_use = non_term_punctuation_interval
			":":
				interval_to_use = non_term_punctuation_interval
			_:
				interval_to_use = text_interval
		
		if text_timer > interval_to_use:
			text_timer = 0.0
			label.visible_characters += 1
			text_beeps.play()
			if label.visible_characters >= len(current_message):
				label.visible_characters = -1
				writing = false
	elif BoardManager.exclusive_text_mode:
		blink_timer -= delta
		if blink_timer < 0.0:
			blink_timer += blink_delay
			if label.text.ends_with("_"):
				label.text = label.text.erase(label.text.length() - 1, 1)
			else:
				label.text += "_"


func new_message(message : Array[String]):
	var printout_message = construct_message(message)
	current_message = printout_message
	label.visible_characters = 0
	label.text = printout_message
	writing = true

func construct_message(message : Array[String]) -> String:
	var return_string = ""
	for line_number in message.size():
		return_string += ">" + message[line_number]
		if line_number < message.size() - 1:
			return_string += "\n"
	return return_string
