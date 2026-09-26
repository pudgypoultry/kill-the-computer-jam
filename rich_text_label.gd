extends RichTextLabel

var text_interval = 0.01
var text_timer = 0.0

func _ready() -> void:
	visible_characters = 0

func _process(delta: float) -> void:
	text_timer += delta
	if text_timer > text_interval:
		text_timer = 0.0
		visible_characters += 1
