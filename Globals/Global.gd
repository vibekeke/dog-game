extends Node

var move_enabled = true
var poop_enabled = true

signal dog_pooped(poop_position)

func create_poop(poop_position):
	if poop_enabled:
		print("Created poop")
		emit_signal("dog_pooped", poop_position)
