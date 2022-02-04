extends Node

var secret_pattern_show = []
var secret_pattern
var button_count = 0
var time = 0
var ColorButton = preload("res://ColorButton.tscn")
var round_won = false
var time_period = 1
var level = []
var level_index = 0

var lvl_pattern = []
var lvl_time = OS.get_time()
var lvl_seed = lvl_time.hour + lvl_time.minute + lvl_time.second

func _ready():
	seed(lvl_seed)
	lvl_pattern = []

	for i in range(0, $HUD.max_button):
		lvl_pattern.append(i)

	lvl_pattern.shuffle()
	
	level = $HUD.get_mode_levels()

	$HUD.max_level = level.size() - 1
	$HUD.set_level(level_index)

func play_round():
	$HUD.set_level(level_index)
	secret_pattern = []

	yield(get_tree().create_timer(1), "timeout")

	round_won = false

	var button_height = int((get_viewport().get_visible_rect().size.y-70) / button_count)
	var cb = false

	for i in range(button_count):
		cb = ColorButton.instance()
		var theme_i = i
		var cb_symbol = ""
		
		if $HUD.is_game_mode($HUD.GAME_MODE_FOLLOW_NAME) or $HUD.is_game_mode($HUD.GAME_MODE_FIND_NAME):
			cb_symbol = String(i)

		if $HUD.is_game_mode($HUD.GAME_MODE_SHUFFLE):
			theme_i = lvl_pattern[i]

		if $HUD.is_game_mode($HUD.GAME_MODE_WORD):
			cb.button_mode = cb.COLOR_WORD

		cb.setup(i, theme_i, button_height, cb_symbol)

		cb.connect("pressed", $".", "button_press")

		secret_pattern.append(cb.name)

		add_child(cb)

	$HUD.z_index = cb.z_index + 1

	if not $HUD.is_game_mode($HUD.GAME_MODE_SHUFFLE) and not $HUD.is_game_mode($HUD.GAME_MODE_WORD):
		secret_pattern.shuffle()

	yield(get_tree().create_timer(2), "timeout")

	secret_pattern_show = secret_pattern.duplicate(true)

	$HUD.show_pattern(secret_pattern)

	yield($HUD, "show_pattern_complete")

	if $HUD.is_game_mode($HUD.GAME_MODE_WORD) or $HUD.is_game_mode($HUD.GAME_MODE_SHUFFLE) or $HUD.is_game_mode($HUD.GAME_MODE_FIND) or $HUD.is_game_mode($HUD.GAME_MODE_FIND_NAME):
		var new_button_order = []

		for i in range(button_count):
			new_button_order.append(i)

		new_button_order.shuffle()

		var i = 0

		for p in new_button_order:
			cb = get_node("Button%s" % String(i))

			if cb:
				cb.move_button(p)

			i += 1

func button_press(name):

	if secret_pattern.size() > 0:
		var cb = get_node(name)

		if name == secret_pattern.front():
			secret_pattern.pop_at(0)
			cb.set_color(cb.COLOR_DOWN)

			if $HUD.is_tap_sound_enabled():
				cb.play_sound()
			cb.pressable(false)
		else:
			$HUD/InfoBar/HealthIndicator.hit()

			if $HUD.is_tap_sound_enabled():
				$Failure.play()
			cb.set_color(cb.COLOR_UP)

	if secret_pattern.size() <= 0:
		round_won = true

		$HUD/InfoBar/HealthIndicator.add_health(1)

		if not $HUD.is_game_mode($HUD.GAME_MODE_SHUFFLE):
			pass # play diddy?

		$RoundTimer.start()

func _on_RoundTimer_timeout():

	for i in range(button_count):
		var cb = get_node("Button%s" % String(i))

		if cb:
			cb.queue_free()

	if round_won:
		level_index += 1

	if level_index >= level.size():
		$HUD.game_loop_end(round_won, level.size() - 1)
		level_index = 0
		button_count = level[level_index]
	else:
		round_won = false
		$HUD.save_level_info(level_index - 1)
		button_count = level[level_index]
		play_round()

func _on_HUD_start_game():
	level = $HUD.get_mode_levels()

	$RoundTimer.start()

func _on_HUD_player_lost():
	$HUD.save_level_info(level_index - 1)
	
	for i in range(button_count):
		var cb = get_node("Button%s" % String(i))

		if cb:
			cb.pressable(false)

	level_index = level.size()
	round_won = false
	$RoundTimer.start()
