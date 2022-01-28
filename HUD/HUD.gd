extends Node2D

const GAME_MODE_FOLLOW_NAME = "Easy"
const GAME_MODE_FIND_NAME = "Medium"
const GAME_MODE_FOLLOW = "Hard"
const GAME_MODE_FIND = "Insain"

const GAME_MODES = [GAME_MODE_FOLLOW_NAME, GAME_MODE_FIND_NAME, GAME_MODE_FOLLOW, GAME_MODE_FIND]

var time = 0
var time_period = 1
var playing = false
var max_level = 0

signal start_game

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

func _process(delta):
	time += delta

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
