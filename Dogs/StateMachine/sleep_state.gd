class_name SleepState
extends State


#ALL STATES NEED THESE:
var state_name = "sleeping"
@onready var dog = $"../.."
@onready var tick_timer = $"../..//TickTimer"
@onready var state_machine = $".."
var sleep_timer

func _ready():
	set_physics_process(false)
	sleep_timer = Timer.new()
	sleep_timer.wait_time = 2
	sleep_timer.timeout.connect(_on_sleep_timer_timeout)
	add_child(sleep_timer)

func _enter_state() -> void:
	#remember to enable physics process if necessary.
	sleep_timer.start()
	dog.can_move = false
	dog.sprite.flip_v = true
	dog.decay_stats["energy"]["decaying"] = false
	dog.decay_stats["energy"]["increasing"] = true

func _exit_state():
	sleep_timer.stop()
	dog.can_move = true
	dog.sprite.flip_v = false
	dog.decay_stats["energy"]["decaying"] = true
	dog.decay_stats["energy"]["increasing"] = false

func _on_sleep_timer_timeout():
	#TODO: if food is nearby
	if dog.get_stat("energy") > 90:
		#do a little wakeup animation and await a timer.
		state_machine.request_state("idle")

func _physics_process(float) -> void:
	pass
