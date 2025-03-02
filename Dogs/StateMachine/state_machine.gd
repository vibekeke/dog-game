extends Node


@onready var tick_timer = $"../TickTimer"
@onready var dog = $".."

@onready var sleep_state = $SleepState
@onready var idle_state = $IdleState
@onready var eat_state = $EatState

var current_state : State



signal pooped(poop_position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_state(idle_state)
	tick_timer.wait_time = 1
	tick_timer.timeout.connect(_check_stats)
	

func _check_stats():
	if dog.get_stat("poop_level") < 40 and Global.poop_enabled:
		poop()
	
	
	if dog.get_stat("energy") < 50 and current_state != eat_state:
		change_state(sleep_state)


func poop():
	print("dog pooped")
	dog.tween_bounce()
	dog.set_stat("poop_level", 100)
	
	#TODO: Might create a spawn point for the poop later, but this is ok
	var random_x = randi_range(-10, 10)
	var random_y = randi_range(-10, 10)
	
	var poop_position = dog.position + Vector2(random_x, random_y)
	
	if dog.sprite.flip_h:
		poop_position = dog.position + Vector2(80, 10)
	else:
		poop_position = dog.position + Vector2(80, -10)
	
	Global.create_poop(poop_position)


func request_state(new_state: String):
	match new_state:
		"idle":
			print("requested idle change")
			change_state(idle_state)
		"eat":
			change_state(eat_state)
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
