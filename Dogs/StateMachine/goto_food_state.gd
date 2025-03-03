class_name GotoFoodState
extends State


var state_name = "goingfood"
@onready var dog = $"../.."
@onready var tick_timer = $"../..//TickTimer"
@onready var state_machine = $".."
var search_timer

var target_food

#TODO: Some sort of system for prioritizing food items.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	search_timer = Timer.new()
	search_timer.wait_time = 2
	search_timer.timeout.connect(_on_search_timer_timeout)
	add_child(search_timer)


func _enter_state() -> void:
	search_timer.start()
	#dog.set_physics_process(false)
	#set_physics_process(true)
	dog.can_sleep = false
	search_for_food()

	
func _exit_state() -> void:
	search_timer.stop()
	#dog.set_physics_process(true)
	#set_physics_process(false)
	dog.target_position = dog.global_position
	dog.can_sleep = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func search_for_food():
	if FoodManager.available_foods.size() > 0:
		target_food = find_closest_food()
		dog.target_position = target_food.global_position
	else:
		state_machine.request_state("idle")
	
	if target_food:
		await target_food.food_entered
		await get_tree().create_timer(1.0).timeout
		state_machine.request_state("eat")

func find_closest_food():
	var closest_food = null
	var closest_distance = INF
	
	for food in FoodManager.available_foods:
		var distance = dog.global_position.distance_to(food.global_position)
		if distance < closest_distance:
			closest_food = food
			closest_distance = distance
	return closest_food

func _on_search_timer_timeout():
	search_for_food()
