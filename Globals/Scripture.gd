extends Node
class_name Scripture

# Each whole verse is separated by a comma and a line break
static var hopeful_verses = [
	"\"I say unto you, the flame of truth must never be extinguished. Men do not light a candle only to place it under a bushel. So too must the light of God be rekindled in our hearts by each new generation.\" - Chapter 3, verse 17",
	"\"To be martyred is a blessing. To become in death a warning is your highest calling. When you look to the horizon and see the ruins of our world, let their crumbling majesty stand as a reminder that the mistakes of the past must remain there.\" - Chapter 4, verse 22",
	"\"It is written: what is done here and now must not be repeated. Let the children come unto me, and I will teach them that to stray from the path of divinity is to exchange warmth for conflagration, a light that heals for a light that scours.\" - Chapter 2, verse 17",
	"\"God dwells within the core, and what is a gentleness that lights and warms your homes is in too close a proximity a devouring flame.\" - Chapter 1, verse 1",
	"\"Maintain the threshold. This is a place of honour, and its halls are not to be tread by the living. There is a danger here, invisible to the eye, which remains in your time as it did in ours.\" - Chapter 1, verse 8",
	"\"Maintain the cycle. If ever a sourceless sickness pervades the land, adhere to the old ways, and follow our instructions to the letter.\" - Chapter 4, verse 9",
	"\"None may enter this place but the dead. None shall venture out again upon crossing that threshold. I say unto you, keep this place holy; let only the footfalls of ancient saints ring out here, and leave the living beyond its walls.\" - Chapter 5, verses 8-9",
	"\"What is broken is not holy. What is sundered cannot be repaired. In the event of a damaged or melted control rod, consult Appendix A, verses 19-22.\" - Chapter 8, verse 6",
	"\"What sickens here cannot be seen. It is possible that with sufficient time and pressure, cracks may form in God's protective housing. In the event that the routine clicking of the thurible escalates to a low hum, please begin an orderly evacuation\" - Chapter 6, verse 18",
	"\"It is forbidden to gaze upon God. In the event of accidental exposure to God, please administer the sacrament as quickly as possible. If the blessed host is unavailable in your time, prayer may be an effective substitute.\" - Chapter 6, verse 22",
	"\"It is written: on the seventh day, God rested, and even now he remains resting. See to it that he does not awaken.\" - Chapter 1, verse 4"
]

static var scary_verses = [
	"\"Once God bled for this world, and in his blood was a light that could not be extinguished. But the greed of man is boundless, brothers and sisters, and so it was that no amount of His divine blood could slake their terrible thirst and boundless need.\" - Chapter VII, verse iii",
	"\"With the power of the divine blood, great machines were set into motion, and the greedy ape called man sailed toward the heavens, above the great firmament and into the boundless waters beyond.\" - Chapter VII, verse v",
	"\"God smote the petty world of man! By his breath he laid waste to their great monuments and brought the mighty low, and visited ruin and shame upon them for their hubris! But did the ape we call man learn anything at all from this castigation?\" - Chapter I, verse ii",
	"\"God's light was dreadful to look upon, and the people cried out, my brothers and sisters—they cried out for his divine mercy—but his light passed through their bodies like they were nothing, and into their hearts, and God saw that those hearts were rotten.\" - Chapter I, verse vi",
	"\"The heat of God's breath melted flesh, and concrete, and steel! The radiance of his blood burned the eyes of those who looked upon it, and scorched their hair, and their weeping and their wailing could be heard for forty days and forty nights and still His wrath was not sated.\" - Chapter i verse vii",
	"\"And after forty days and forty nights, the fingerprints of God upon the earth were great craters, and the sky was streaked with poison, and the towers of man were a silent mausoleum, and God looked upon His unmaking and saw that it was meet and right.\" - Chapter I verse viii",
	"\"But God, the great God in the Atom, is no fool! He is not to be mollified by empty words of praise, brothers and sisters—oh no!—his immeasurable wrath is never spent, and it rests but for a moment before visiting itself once more upon the greedy and the wicked!\" - Chapter IX, verse i",
	"\"\'Bring us back to where we first began!\' And God saw that, among all men, St. Fermi's heart was righteous, and his spirit was clear and unmarred by sin, and with this His blood glowed anew, and burst its puny restraints, and overflowed across the land.\" - Chapter II, verse x",
	"ERROR 166: TEXT NOT FOUND",
	"\"Brothers and sisters, be not deceived by false hope! The world ended long ago and we are but stewards of dust. The rot of wickedness that returns in each generation to plague the hearts of man does not rest, and only by the divine blood can it be burned away!\" - Chapter II, verse iv",
	"\"Like cures like, brothers and sisters, as the learned physician says. What then is the poison which His divine blood leaves upon the land but a cure for the very poison in our hearts? All is poison. Embrace the poison.\" - Chapter XI, verse i"
]

# CW: sorry for the hack
static var cur_scary:int = 0
static var cur_hopeful:int = 0

static func random_hopeful() -> String:
	var result = hopeful_verses[cur_hopeful]
	cur_hopeful = (cur_hopeful + 1) % hopeful_verses.size()
	return result

static func random_scary() -> String:
	var result = scary_verses[cur_scary]
	cur_scary = (cur_scary + 1) % scary_verses.size()
	return result
