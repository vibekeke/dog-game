extends Node

var last_recorded_time: float
var current_time : float
var update_interval : float = 30.0
var time_passed

@onready var update_timer = Timer.new()

signal time_updated(time_passed)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_recorded_time = int(Time.get_unix_time_from_system())
	current_time = int(Time.get_unix_time_from_system())
	
	add_child(update_timer)
	update_timer.wait_time = update_interval
	update_timer.timeout.connect(_on_update_timer_timeout)
	update_timer.start()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_update_timer_timeout():
	current_time = int(Time.get_unix_time_from_system())
	time_passed = current_time - last_recorded_time
	
	if time_passed < 0:
		print("Dogs are allergic to Time Travel!")
		return
	
	last_recorded_time = current_time
	emit_signal("time_updated", time_passed)
	
func debug_time_changed(time_passed):
	print("Time skipped (debug): " + str(time_passed))
	emit_signal("time_updated", time_passed)



	
	
	
