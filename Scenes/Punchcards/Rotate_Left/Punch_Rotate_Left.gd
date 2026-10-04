extends PunchCard

func execute() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")


func execute_a() -> void:
	super()
	reactor.talk()


func execute_b() -> void:
	super()
	print("Rotating Left")
	reactor.turn("left")
