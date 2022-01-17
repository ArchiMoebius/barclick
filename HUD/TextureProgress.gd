extends TextureProgress

export var cooldown = 1.0

func _ready():
	$".".value = 0
	$LoadingTimer.wait_time = cooldown
	set_process(false)

func start():
	set_process(true)
	$LoadingTimer.start()

func _process(delta):
	$".".value = int(($LoadingTimer.time_left / cooldown) * 100)

func _on_LoadingTimer_timeout():
	$".".value = 0
	$LoadingTimer.wait_time = cooldown
	set_process(false)
