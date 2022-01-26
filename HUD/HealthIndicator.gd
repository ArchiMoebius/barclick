extends Node2D

var health = 0
var count = 3
var HeartSprite = preload("res://HUD/HeartSprite.tscn")
var time = 0
var time_period = 1

func _ready():
	for i in range(count):

		var hs = HeartSprite.instance()
		var hs_rect = hs.get_sprite_frames().get_frame("full",0).get_size()

		hs.name = "heartSprite%s" % String(i)
		hs.set_full()
		hs.position.x += hs_rect.length()/2*i

		$HealthContainer.add_child(hs)

	health = count

func add_health(amount):
	if health + amount <= count:
		for i in range(health, health+amount, 1):
			var hs = $HealthContainer.get_node("heartSprite%s" % String(i))

			if hs:
				hs.set_full()
		
		health += amount

func reset_health():
	health = count

	for i in range(count):
		var hs = $HealthContainer.get_node("heartSprite%s" % String(i))

		if hs:
			hs.set_full()

func hit():

	if health - 1 > 0:
		health -= 1
	else:
		health = 0

	for i in range(count-1, -1, -1):

		if i >= health:
			var hs = $HealthContainer.get_node("heartSprite%s" % String(i))

			if hs:
				hs.set_empty()
