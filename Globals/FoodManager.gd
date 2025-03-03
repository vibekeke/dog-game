extends Node


signal fill_bowl_requested
signal new_food_available

var available_foods = []

func register_food(food : Node):
	if food not in available_foods:
		available_foods.append(food)
	emit_signal("new_food_available")
	print(available_foods)

func deregister_food(food : Node):
	available_foods.erase(food)


func request_fill_bowl():
	emit_signal("fill_bowl_requested")
