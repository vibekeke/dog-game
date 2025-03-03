extends Node


@onready var tick_timer = $"../TickTimer"
@onready var dog = $".."

@onready var sleep_state = $SleepState
@onready var idle_state = $IdleState
@onready var eat_state = $EatState
@onready var goto_food_state = $GotoFoodState

var current_state : State



signal pooped(poop_position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state(idle_state)
	tick_timer.wait_time = 1
	tick_timer.timeout.connect(_check_stats)
	
	FoodManager.new_food_available.connect(_on_new_food_available)

func _check_stats():
	if dog.get_stat("poop_level") < 40 and Global.poop_enabled:
		poop()
	
	if FoodManager.available_foods.size() > 0 and dog.get_stat("hunger") <= 110 and dog.can_eat:
		change_state(goto_food_state)
	if dog.get_stat("energy") < 50 and dog.can_sleep:
		change_state(sleep_state)

func _on_new_food_available():
	_check_stats()
	pass


func poop():
	print("dog pooped")
	dog.tween_bounce()
	dog.change_stat("poop_level", 100)
	
	#TODO: Might create a spawn point for the poop later, but this is ok
	var random_x = randi_range(-10, 10)
	var random_y = randi_range(-10, 10)
	
	var poop_position = dog.position + Vector2(random_x, random_y)
	
	if dog.sprite.flip_h:
		poop_position +=  Vector2(-80, 5)
	else:
		poop_position += Vector2(80, 5)
	
	Global.create_poop(poop_position)


func request_state(new_state: String):
	match new_state:
		"idle":
			change_state(idle_state)
		"eat":
			change_state(eat_state)
		"goto_food":
			change_state(goto_food_state)
		_:
			print("WARNING: Unknown state requested!")

func change_state(new_state: State):
	if current_state == new_state:
		return
		
	if current_state:
		current_state._exit_state()
	if new_state:
		new_state._enter_state()
		print("New state: " + new_state.state_name)
	current_state = new_state
