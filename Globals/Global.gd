extends Node

var move_enabled = true
var poop_enabled = true

signal new_food_available

const MAX_POOPS = 20

func can_poop():
	return poop_enabled and get_tree().get_nodes_in_group("poop").size() < MAX_POOPS
