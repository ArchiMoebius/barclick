extends Node2D

const COLOR_UP = "up"
const COLOR_DOWN = "down"
const COLOR_WORD = "color_word"

var sound_player = AudioStreamPlayer.new()
var theme_index = 0

const THEMES = [
	{
		"word": "Red",
		"up": "#ff0000",
		"down": "#35353B",
		"sound": preload("res://sounds/blue.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Orange",
		"up": "#ff4700",
		"down": "#35353B",
		"sound": preload("res://sounds/green.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Yellow",
		"up": "#ffea00",
		"down": "#35353B",
		"sound": preload("res://sounds/grass.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Green",
		"up": "#0db62f",
		"down": "#35353B",
		"sound": preload("res://sounds/yellow.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Cyan",
		"up": "#00eafa",
		"down": "#35353B",
		"sound": preload("res://sounds/orange.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Blue",
		"up": "#000490",
		"down": "#35353B",
		"sound": preload("res://sounds/red.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Indigo",
		"up": "#3c04aa",
		"down": "#35353B",
		"sound": preload("res://sounds/pink.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	},
	{
		"word": "Violet",
		"up": "#942de3",
		"down": "#35353B",
		"sound": preload("res://sounds/violet.wav"),
		"symbol_color": "#9B9BA1",
		"color_word": "#bec4dd"
	}
]

var button_theme
var button_height
var button_mode = ""

signal pressed(name)

func setup(index, t_idx, height, symbol):
	button_height = height

	$".".resize(height)
	$".".name = "Button%s" % String(index)

	set_theme(t_idx)
	move_button(index)

	if button_mode == COLOR_WORD:
		symbol = button_theme["word"]

	$Button.text = symbol

func move_button(index):
	$".".position.y = index * button_height + 70

func set_theme(index):
	button_theme = THEMES[index % THEMES.size()]
	theme_index = index

	$Button.set("custom_colors/font_color_disabled", button_theme["symbol_color"])
	$Button.set("custom_colors/font_color_focus", button_theme["symbol_color"])
	$Button.set("custom_colors/font_color", button_theme["symbol_color"])
	$Button.set("custom_colors/font_color_hover", button_theme["down"])
	$Button.set("custom_colors/font_color_pressed", "#68686E")

func set_color(direction):
	$ColorRect.color = button_theme["%s" % direction]

func _ready():

	if button_mode == COLOR_WORD:
		set_color(COLOR_WORD)
		$Button.set("custom_colors/font_color", button_theme[COLOR_UP])
		$Button.set("custom_colors/font_color_disabled", button_theme[COLOR_UP])
		$Button.set("custom_colors/font_color_focus", button_theme[COLOR_UP])
		$Button.set("custom_colors/font_color", button_theme[COLOR_UP])
		$Button.set("custom_colors/font_color_hover", button_theme["down"])
	else:
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

func press(up_delay):
	set_color(COLOR_DOWN)
	
	if $".".get_parent().get_node("HUD").is_tap_sound_enabled():
		play_sound()

	$ResetButtonUpTimer.start(up_delay)

func play_sound():
	sound_player.set_stream(button_theme["sound"])
	sound_player.volume_db = 1
	sound_player.pitch_scale = 1
	sound_player.play()

func _on_ResetButtonUpTimer_timeout():
	set_color(COLOR_UP)
