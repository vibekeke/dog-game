class_name IdleState
extends State



#ALL STATES NEED THESE:
var state_name = "idle"
@onready var dog = $"../.."
@onready var tick_timer = $"../../TickTimer"
@onready var state_machine = $".."

var move_frequency = 5 #max amount of wait time.
var min_distance = 80
var max_distance = 300

var idle_timer

func _ready():
	set_physics_process(false)
	
	idle_timer = Timer.new()
	idle_timer.wait_time = 4
	idle_timer.timeout.connect(on_idle_timer_timeout)
	add_child(idle_timer)
	

func _enter_state() -> void:
	idle_timer.start()
	pass
	
func _exit_state() -> void:
	idle_timer.stop()
	pass


func on_idle_timer_timeout():
	#TODO: if player_just_called and discipline < threshold: don't move. Else:
	
	pick_random_target()


func pick_random_target():
	var random_x = randi_range(min_distance, max_distance)
	var random_y = randi_range(min_distance, max_distance)
	random_x = random_x * [-1, 1].pick_random() #makes positive or negative direction
	random_y = random_y * [-1, 1].pick_random()
	
	var screen_size = get_viewport().size
	
	
	var new_x = clamp(dog.global_position.x + random_x, 100, screen_size.x)
	var new_y = clamp(dog.global_position.y + random_y, 200, screen_size.y)
	
	var new_position = Vector2(new_x, new_y)
	dog.target_position = new_position
	
	var random_time = randf_range(0.5, move_frequency)
	idle_timer.wait_time = random_time
	idle_timer.start()
	dog.target_position
	
