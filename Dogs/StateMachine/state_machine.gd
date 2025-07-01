extends Node


@onready var tick_timer = $"../TickTimer"
@onready var dog = $".."

@onready var sleep_state = $SleepState
@onready var idle_state = $IdleState
@onready var eat_state = $EatState
@onready var goto_food_state = $GotoFoodState

var current_state : State

@onready var debug_timer = $"../DebugTimer"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state(idle_state)
	tick_timer.wait_time = 1
	tick_timer.timeout.connect(_check_stats)
	debug_timer.timeout.connect(_on_debug_timer_timeout)
	
	Global.new_food_available.connect(_on_new_food_available)

func _check_stats():
	print(dog.dog_name + " can sleep: " + str(dog.can_sleep))
	if dog.get_stat("poop_level") < 40 and Global.can_poop():
		dog.poop()
	
	if dog.get_stat("hunger") <= 110 and dog.can_eat:
		if get_tree().get_nodes_in_group("food").size() > 0:
			change_state(goto_food_state)

	if dog.get_stat("energy") < 50 and dog.can_sleep:
		change_state(sleep_state)

func _on_new_food_available():
	_check_stats()
	pass


func reset_state():
	change_state(idle_state)
	_check_stats()

func request_state(new_state: String):
	match new_state:
		"reset":
			reset_state()
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

func _on_debug_timer_timeout():
	print(dog.dog_name + ", current state: " +  current_state.state_name)
