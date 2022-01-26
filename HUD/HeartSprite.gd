extends AnimatedSprite

const STATE_FULL = "full"
const STATE_EMPTY = "empty"

func _ready():
	$".".animation = STATE_FULL

func set_empty():
	$".".animation = STATE_EMPTY

func set_full():
	$".".animation = STATE_FULL
