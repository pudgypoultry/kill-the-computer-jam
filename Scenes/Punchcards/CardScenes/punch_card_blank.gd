extends PunchCard

func _ready() -> void:
	super()
	BoardManager.blank_cards.append(self)


func execute() -> void:
	super()
	return


func execute_a() -> void:
	super()
	reactor.show_blank_punchcard_error()


func execute_b() -> void:
	super()
	reactor.show_blank_punchcard_error()
