extends Node2D

const GAME_MODE_WORD = "Words-to-Color"
const GAME_MODE_SHUFFLE = "Shuffle"
const GAME_MODE_FOLLOW_NAME = "Easy"
const GAME_MODE_FIND_NAME = "Medium"
const GAME_MODE_FOLLOW = "Hard"
const GAME_MODE_FIND = "Insain"

const GAME_MODES = [GAME_MODE_WORD, GAME_MODE_SHUFFLE, GAME_MODE_FOLLOW_NAME, GAME_MODE_FIND_NAME, GAME_MODE_FOLLOW, GAME_MODE_FIND]

var time = 0
var time_period = 1
var playing = false
var max_level = 0
var max_button = 8

signal start_game
signal player_lost
signal show_pattern_complete

func _ready():

	for i in range(GAME_MODES.size()):
		$GameModeNode/Options.add_item(GAME_MODES[i], i+1)

	$".".show()
	$HealthIndicator.hide()
	$LoadScreenAudioStream.play()
	$Level.hide()

func is_game_mode(mode):
	return GAME_MODES[$GameModeNode/Options.get_selected_id()-1] == mode

func set_level(level):
	$Level.text = "%s/%s" % [String(level), max_level]

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


func _process(delta):
	time += delta

	if time > time_period and $HealthIndicator.health <= 0:
		$HealthIndicator.reset_health()
		$HealthIndicator.hide()
		$Loading.start()
		emit_signal("player_lost")
		time = 0

	if time > time_period and not playing and not $LoadScreenAudioStream.playing:
		$LoadScreenAudioStream.play()
		time = 0

	if time > time_period and playing and not $GamePlayAudioStream.playing:
		$GamePlayAudioStream.play()
		time = 0
		$Level.show()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func _on_StartButton_pressed():
	$Loading.start()
	$StartButton.hide()
	$QuitButton.hide()
	$GameModeNode.hide()
	$Title.hide()
	$Message.hide()
	$HealthIndicator.show()
	$LoadScreenAudioStream.stop()

	playing = true

	emit_signal("start_game")

func game_loop_end(round_won):
	$Level.hide()
	set_level(0)

	$HealthIndicator.reset_health()

	if round_won:
		round_won = false
		$Message.text = "What...How?!...You're simply amazing!"
	else:
		$Message.text = "Well, that was close - but you can only fail three times!..."

	$StartButton.text = "Go again?"
	$Message.show()
	$StartButton.show()
	$QuitButton.show()

	$GameModeNode.z_index = 999
	$GameModeNode.show()

	$GamePlayAudioStream.stop()
	$LoadScreenAudioStream.stop()

	playing = false

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_QuitButton_pressed():
	get_tree().quit()
