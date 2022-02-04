extends Node

# Thank you https://gdscript.com/solutions/how-to-save-and-load-godot-game-data/!!!
const FILE_NAME = "user://barclick_state.json"

var state = {}

func _ready():
	var HUD = $".".get_parent()

	state["last_mode"] = HUD.GAME_MODE_WORD

	for i in range(HUD.GAME_MODES.size()):
		state["%s" % HUD.GAME_MODES[i]] = {"last": 0, "high": HUD.get_mode_high(HUD.GAME_MODES[i])}

	load_data()

func set_highs():
	var HUD = $".".get_parent()

	for i in range(HUD.GAME_MODES.size()):
		state["%s" % HUD.GAME_MODES[i]]["high"] = HUD.get_mode_high(HUD.GAME_MODES[i])

func get_last_mode():
	return state["last_mode"]

func get_mode_info(mode):
	return state["%s" % mode]

func set_last_level(game_mode, level):
	state["last_mode"] = game_mode

	if state["%s" % game_mode]["high"] > level:
		state["%s" % game_mode]["high"] = level

	state["%s" % game_mode]["last"] = level

func save_data():
	set_highs()

	var file = File.new()

	file.open(FILE_NAME, File.WRITE)
	file.store_string(to_json(state))
	file.close()

func load_data():
	var file = File.new()

	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)

		var data = parse_json(file.get_as_text())

		file.close()

		if typeof(data) == TYPE_DICTIONARY:
			state = data
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
