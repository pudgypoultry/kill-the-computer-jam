extends Node
class_name Scripture

# Each whole verse is separated by a comma and a line break
static var hopeful_verses = [
	"Hopeful Example 1",
	"Hopeful Example 2",
	"Hopeful Example 3"
]


static var scary_verses = [
	"Scary Example 1",
	"Scary Example 2",
	"Scary Example 3"
]


static func random_hopeful() -> String:
	return hopeful_verses.pick_random()


static func random_scary() -> String:
	return scary_verses.pick_random()
