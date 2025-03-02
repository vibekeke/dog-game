class_name EatState
extends State

#ALL STATES NEED THESE:
var state_name = "eating"
@onready var dog = $"../.."
@onready var tick_timer = $"../..//TickTimer"
@onready var state_machine = $".."

var eat_timer

func _ready():
	set_physics_process(false)
	eat_timer = Timer.new()
	eat_timer.wait_time = 2
	eat_timer.timeout.connect(_on_eat_timer_timeout)

func _enter_state() -> void:
	dog.can_move = false
	dog.decay_stats["hunger"]["decaying"] = false
	dog.decay_stats["hunger"]["increasing"] = true
	
	dog.multipliers["poop_level"]["decay_increase"] += 0.3
	
func _exit_state() -> void:
	eat_timer.stop()
	dog.can_move = true
	dog.decay_stats["hunger"]["decaying"] = true
	dog.decay_stats["hunger"]["increasing"] = false
	
	dog.multipliers["poop_level"]["decay_increase"] -= 0.3
	#Will exit when finished eating, duhh.

func _on_eat_timer_timeout():
	if dog.get_stat("hunger") > dog.max_stat:
		state_machine.request_state("idle")
