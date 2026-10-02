extends MarginContainer
class_name TerminalManager

@export var text_interval = 0.01
@export var text_timer = 0.0

@export var label : RichTextLabel

var writing : bool = true
var current_message : String = ">"

func _ready() -> void:
	label.visible_characters = 0
	new_message([label.text, label.text])


func _process(delta: float) -> void:
	if writing:
		text_timer += delta
		if text_timer > text_interval:
			text_timer = 0.0
			label.visible_characters += 1
			if label.visible_characters > len(current_message):
				writing = false


func new_message(message : Array[String]):
	var printout_message = construct_message(message)
	current_message = printout_message
	label.visible_characters = 0
	label.text = printout_message
	writing = true


func construct_message(message : Array[String]) -> String:
	var return_string = ""
	for line in message:
		return_string += ">" + line
		return_string += "\n\n"
	return return_string
