extends PunchCard

func execute() -> void:
	super()
	print_debug("Examining")


func execute_a() -> void:
	super()
	print("Examining")
	reactor.examine()


func execute_b() -> void:
	super()
	print("Talking")
	reactor.talk()
