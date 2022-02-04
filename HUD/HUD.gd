extends Node2D

const GAME_MODE_WORD = "Words-to-Color"
const GAME_MODE_SHUFFLE = "Shuffle"
const GAME_MODE_FOLLOW_NAME = "Number Follow"
const GAME_MODE_FIND_NAME = "Mix-Number"
const GAME_MODE_FOLLOW = "Color Follow"
const GAME_MODE_FIND = "Mix-Color"

const GAME_MODES = [GAME_MODE_WORD, GAME_MODE_SHUFFLE, GAME_MODE_FOLLOW_NAME, GAME_MODE_FIND_NAME, GAME_MODE_FOLLOW, GAME_MODE_FIND]

export var game_mode_levels = {}

var time = 0
var time_period = 1
var playing = false
var max_level = 0
var max_button = 8
var setting_music_enabled = true
var setting_tapsound_enabled = true
var player_back = false

signal start_game
signal player_lost
signal show_pattern_complete

func _ready():
	game_mode_levels["%s" % GAME_MODE_WORD] = [1, 2, 3, 4, 5, 5, 5, 6, 7, 8]
	game_mode_levels["%s" % GAME_MODE_SHUFFLE] = [2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8]
	game_mode_levels["%s" % GAME_MODE_FOLLOW_NAME] = [2, 3, 4, 5, 5, 6, 7, 8]
	game_mode_levels["%s" % GAME_MODE_FIND_NAME] = [2, 3, 4, 5, 6, 5, 6, 7, 8]
	game_mode_levels["%s" % GAME_MODE_FOLLOW] = [2, 3, 4, 5, 5, 5, 6, 7, 7, 8, 8]
	game_mode_levels["%s" % GAME_MODE_FIND] = [3, 3, 4, 5, 5, 6, 6, 7, 7, 8, 8]

	for i in range(GAME_MODES.size()):
		$TabContainer/GameModeTab/SC/Mode.add_item("%s" % GAME_MODES[i])

	load_game_modes()

	$TabContainer.set_tab_title ( 0, "Game Mode" )
	$TabContainer.set_tab_title ( 1, "Settings" )

	$".".show()

	$InfoBar.hide()

	if setting_music_enabled:
		$LoadScreenAudioStream.play()

	$InfoBar/Level.hide()
	$TabContainer.show()

func get_mode_high(mode):
	if game_mode_levels.has(mode):
		return game_mode_levels["%s" % mode].size() - 1
	else:
		return 0

func get_mode_levels():
	var levels = game_mode_levels["%s" % get_game_mode()]

	max_level = levels.size() - 1

	set_level(0)

	return levels

func load_game_modes():
	$State.set_highs()

	for i in range(GAME_MODES.size()):
		var mode_info = $State.get_mode_info(GAME_MODES[i])

		var tag = "%s of %s" % [String(mode_info["last"]), String(mode_info["high"])]
		
		if mode_info["high"] > 0 and mode_info["last"] >= mode_info["high"]:
			tag = "GOLD"

		$TabContainer/GameModeTab/SC/Mode.set_item_text(i, "%s : %s" % [tag, GAME_MODES[i]])

	$TabContainer/GameModeTab/SC/Mode.select(get_game_mode_index($State.get_last_mode()), true)

func save_level_info(level):

	if level <= 0:
		level = 0

	$State.set_last_level(get_game_mode(), level)

func get_game_mode_index(mode):
	var ret = 0
	
	for i in range(GAME_MODES.size()):
		if GAME_MODES[i] == mode:
			ret = i
			break

	return ret

func get_game_mode():
	return GAME_MODES[$TabContainer/GameModeTab/SC/Mode.get_selected_items()[0]]

func is_game_mode(mode):
	return GAME_MODES[$TabContainer/GameModeTab/SC/Mode.get_selected_items()[0]] == mode

func set_level(level):
	$InfoBar/Level.text = "%s/%s" % [String(level), max_level]

func show_pattern(secret_pattern):
	
	var secret_pattern_show = secret_pattern.duplicate(true)

	yield(get_tree().create_timer(1), "timeout")

	#if not is_game_mode(GAME_MODE_SHUFFLE): # and setting_skip_show_pattern
	while secret_pattern_show.size() > 0:
		var cb = $".".get_parent().get_node(secret_pattern_show.pop_at(0))

		if cb:
			cb.pressable(false)
			cb.press(0.6)

		yield(get_tree().create_timer(1), "timeout")

	for i in range(secret_pattern.size()):
		var cb = $".".get_parent().get_node(secret_pattern[i])

		if cb:
			cb.pressable(true)
			cb.set_theme(cb.theme_index)
			cb.set_color(cb.COLOR_UP)
			
			if cb.button_mode == cb.COLOR_WORD:
				cb.get_node("Button").text = ""
			
			cb.button_mode = ""

	emit_signal("show_pattern_complete")

func is_tap_sound_enabled():
	return setting_tapsound_enabled

func _process(delta):
	time += delta

	if time > time_period:
		handle_audio()
		time = 0
		
		if $InfoBar/HealthIndicator.health <= 0:
			$InfoBar/HealthIndicator.reset_health()
			$InfoBar/HealthIndicator.hide()
			$Loading.start()
			emit_signal("player_lost")

func handle_audio():

	if !setting_music_enabled:
		$LoadScreenAudioStream.stop()
		$GamePlayAudioStream.stop()
		return

	if setting_music_enabled and not playing and not $LoadScreenAudioStream.playing:
		$LoadScreenAudioStream.play()

	if setting_music_enabled and playing and not $GamePlayAudioStream.playing:
		$GamePlayAudioStream.play()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func _on_StartButton_pressed():
	$Loading.start()
	$StartButton.hide()
	$QuitButton.hide()
	$TabContainer.hide()
	$Title.hide()
	$Message.hide()
	$InfoBar/HealthIndicator.show()
	$InfoBar/Level.show()
	$LoadScreenAudioStream.stop()
	$InfoBar.show()

	playing = true

	emit_signal("start_game")

func game_loop_end(round_won, last_level):
	$InfoBar.hide()
	$InfoBar/Level.hide()
	set_level(0)

	$InfoBar/HealthIndicator.reset_health()

	if round_won:
		$Message.text = "What...How?!...You're simply amazing! Try another?"
		save_level_info(last_level)
	else:
		if not player_back:
			$Message.text = "Well, that was close - but you can only fail three times!..."
		else:
			$Message.text = "If you don't like that game mode - try another!"

	$StartButton.text = "Go again?"
	$Message.show()
	$Title.show()
	$StartButton.show()
	$QuitButton.show()

	$TabContainer.show()

	$GamePlayAudioStream.stop()
	$LoadScreenAudioStream.stop()

	load_game_modes()

	playing = false
	player_back = false
	round_won = false

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_QuitButton_pressed():
	quit()

func _on_Music_toggled(button_pressed):
	setting_music_enabled = button_pressed

	handle_audio()

func _on_TapSound_toggled(button_pressed):
	setting_tapsound_enabled = button_pressed

func _on_Exit_pressed():
	$State.save_data()

	player_back = true
	emit_signal("player_lost")

func quit():
	$State.save_data()

	yield(get_tree().create_timer(0.1), "timeout") # force file sync/flush?

	get_tree().quit()
