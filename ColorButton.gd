extends Node2D

const COLOR_UP = "up"
const COLOR_DOWN = "down"

var sound_player = AudioStreamPlayer.new()
var theme_index = 0

const THEMES = [
	{
		"up": "#0D0D92", # Ultramarine
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/blue.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#008309", # Ao
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/green.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#00675C", # Teal Green
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/grass.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#A74700", # Brown
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/yellow.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#A70400", # Dark Candy Apple Red
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/orange.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#829800", # Heart Gold
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/red.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#5D0166", # Indigo
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/pink.wav"),
		"symbol_color": "#9B9BA1"
	},
	{
		"up": "#9C7500", # Drab
		"down": "#35353B", # Dark Lava
		"sound": preload("res://sounds/violet.wav"),
		"symbol_color": "#9B9BA1"
	}
]

var button_theme
var button_height

signal pressed(name)

func setup(index, height, symbol):
	button_height = height
	
	$".".resize(height)
	$".".name = "Button%s" % String(index)
	
	$Button.text = symbol

	set_theme(index)
	move_button(index)

func move_button(index):
	$".".position.y = index * button_height

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
	$ResetButtonUpTimer.start(up_delay)

func play_sound():
	sound_player.set_stream(button_theme["sound"])
	sound_player.volume_db = 1
	sound_player.pitch_scale = 1
	sound_player.play()

func _on_ResetButtonUpTimer_timeout():
	set_color(COLOR_UP)
	play_sound()
