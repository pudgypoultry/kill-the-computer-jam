extends PunchCard

func _ready() -> void:
	super()
	BoardManager.blank_cards.append(self)


func execute() -> void:
	super()
	return


func execute_a() -> void:
	super()
	BoardManager.reactor_manager.insert_blank_card()


func execute_b() -> void:
	super()
	BoardManager.reactor_manager.insert_blank_card()
