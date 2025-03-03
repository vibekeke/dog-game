extends Node


signal fill_bowl_requested

var available_foods = []

func register_food(food : Node):
	available_foods.append(food)

func deregister_food(food : Node):
	available_foods.erase(food)


func request_fill_bowl():
	emit_signal("fill_bowl_requested")
