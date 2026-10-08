extends PunchCard

func execute() -> void:
	super()
	return


func execute_a() -> void:
	super()
	reactor.print_new_card(self)


func execute_b() -> void:
	super()
	reactor.print_new_card(self)
