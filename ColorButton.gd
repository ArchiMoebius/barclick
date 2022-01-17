extends Node2D

const COLOR_UP = "up"
const COLOR_DOWN = "down"

var sound_player = AudioStreamPlayer.new()

var button_colors = {
	"Button0_up": "#28536C",
	"Button0_down": "#02314D",
	"Button0_sound": preload("res://sounds/blue.wav"),
	"Button1_up": "#2D8828",
	"Button1_down": "#006000",
	"Button1_sound": preload("res://sounds/green.wav"),
	"Button2_up": "#86A136",
	"Button2_down": "#557200",
	"Button2_sound": preload("res://sounds/grass.wav"),
	"Button3_up": "#AA9B39",
	"Button3_down": "#796900",
	"Button3_sound": preload("res://sounds/yellow.wav"),
	"Button4_up": "#AA7739",
	"Button4_down": "#794200",
	"Button4_sound": preload("res://sounds/orange.wav"),
	"Button5_up": "#AA3939",
	"Button5_down": "#790000",
	"Button5_sound": preload("res://sounds/red.wav"),
	"Button6_up": "#7F2A68",
	"Button6_down": "#5A0041",
	"Button6_sound": preload("res://sounds/pink.wav"),
	"Button7_up": "#462E74",
	"Button7_down": "#1F0452",
	"Button7_sound": preload("res://sounds/violet.wav"),
}

signal pressed(name)

func set_color(direction):
	$ColorRect.color = button_colors["%s_%s" % [$".".name, direction]]
	
func _ready():
	set_color(COLOR_UP)
	pressable(false)

	add_child(sound_player)

func pressable(state):
	$Button.disabled = !state

func resize(height):
	$ColorRect.rect_size.y = height
	$Button.rect_size.y = height

func _on_Button_pressed():
	if not $Button.disabled:
		emit_signal("pressed", $".".name)

func press():
	set_color(COLOR_DOWN)
	$ResetButtonUpTimer.start(0.5)

func play_sound():
	sound_player.set_stream(button_colors["%s_sound" % $".".name])
	sound_player.volume_db = 1
	sound_player.pitch_scale = 1
	sound_player.play()

func _on_ResetButtonUpTimer_timeout():
	set_color(COLOR_UP)
	play_sound()
