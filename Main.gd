extends Node

var secret_pattern_show = []
var secret_pattern
var button_count = 0
var time = 0
var ColorButton = preload("res://ColorButton.tscn")
var round_won = false
var time_period = 1
var level = [1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 8]
var level_index = 0

func _ready():
	randomize()

func play_round():
	$HUD.set_level(level_index)
	secret_pattern = []

	yield(get_tree().create_timer(1), "timeout")

	round_won = false

	var button_height = int(get_viewport().get_visible_rect().size.y/button_count)
	var cb = false

	for i in range(button_count):
		cb = ColorButton.instance()
		cb.name = "Button%s" % String(i)

		cb.position.y = i * button_height

		cb.connect("pressed", $".", "button_press")
		cb.resize(button_height)

		secret_pattern.append(cb.name)
		
		add_child(cb)

	$HUD.z_index = cb.z_index + 1
	$HUD/HealthBarNode/HealthBar.show()

	secret_pattern.shuffle()

	yield(get_tree().create_timer(2), "timeout")

	secret_pattern_show = secret_pattern.duplicate(true)

func button_press(name):

	if secret_pattern.size() > 0:
		var cb = get_node(name)

		if name == secret_pattern.front():
			secret_pattern.pop_at(0)
			cb.set_color(cb.COLOR_DOWN)
			cb.pressable(false)
			cb.play_sound()
		else:
			$HUD/HealthBarNode/HealthBar.value -= 1
			$Failure.play()
			cb.set_color(cb.COLOR_UP)

	if secret_pattern.size() <= 0:
		round_won = true
		time_period = 0.1

		if $HUD/HealthBarNode/HealthBar.value < 3:
			$HUD/HealthBarNode/HealthBar.value += 1
		
		for i in range(button_count):
			secret_pattern_show.append("Button%s" % String(i))

func _process(delta):
	time += delta

	if time > time_period and $HUD/HealthBarNode/HealthBar.value <= 0:
		level_index = level.size()
		$HUD/HealthBarNode/HealthBar.value = 3
		$HUD/HealthBarNode/HealthBar.hide()
		$RoundTimer.start()
		$HUD/Loading.start()
		round_won = false
		time = 0

	if secret_pattern_show.size() > 0:

		if time > time_period:
			time = 0

			var cb = get_node(secret_pattern_show.pop_at(0))

			if cb:
				cb.press()

		if secret_pattern_show.size() <= 0:
			time_period = 1

			for s in secret_pattern:
				var cb = get_node(s)

				if cb:
					cb.pressable(true)

			if round_won:
				$RoundTimer.start()

func _on_RoundTimer_timeout():

	for i in range(button_count):
		var cb = get_node("Button%s" % String(i))

		if cb:
			cb.queue_free()

	if round_won:
		level_index += 1

	round_won = false

	if level_index >= level.size():
		$HUD.game_loop_end(round_won)
		level_index = 0
		button_count = level[level_index]
	else:
		button_count = level[level_index]
		play_round()

func _on_HUD_start_game():
	$RoundTimer.start()
