extends Node2D

var time = 0
var time_period = 1
var playing = false

signal start_game

func _ready():
	$".".show()
	$HealthBarNode/HealthBar.hide()
	$LoadScreenAudioStream.play()
	$Level.hide()

func set_level(level):
	$Level.text = String(level)

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
	$Title.hide()
	$Message.hide()
	$HealthBarNode/HealthBar.show()
	$LoadScreenAudioStream.stop()
	playing = true

	emit_signal("start_game")

func game_loop_end(round_won):
	$Level.hide()
	set_level(0)

	$HealthBarNode/HealthBar.value = 3

	if round_won:
		round_won = false
		$Message.text = "What...How?!...You're simply amazing!"
	else:
		$Message.text = "Well, that was close - but you can only fail three times!..."

	$StartButton.text = "Go again?"
	$Message.show()
	$StartButton.show()
	$QuitButton.show()

	$GamePlayAudioStream.stop()
	$LoadScreenAudioStream.stop()

	playing = false

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_QuitButton_pressed():
	get_tree().quit()
