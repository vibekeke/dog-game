extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var tick_timer = $TickTimer
@onready var state_machine = $StateMachine

var move_speed = 300
var move_multiplier = 1.0 #should be affected by moods and personality UwU

var target_position = Vector2()
var target_vector = Vector2()
var sceen_size
var can_move = true
var last_position = Vector2()

var stat_max = 120

signal pooped
signal stats_updated(decay_stats, love) #TODO: HUD will fetch stats from DogManager, not the dog script!
signal stat_increased(stat: String) #For visual effects purposes (EffectsLayer!)
signal stat_decreased(stat: String) #For visual effects purposes (EffectsLayer!)


var decay_stats = {
	"hunger" : {"value" : 70, "decaying" : true, "increasing" : false},
	"energy" : {"value" : 70, "decaying" : true, "increasing" : false},
	"fun" : {"value" : 70, "decaying" : true, "increasing" : false},
	#Hidden  stats
	"poop_level" : {"value" : 100, "decaying" : true, "increasing" : false},
	"hygiene" : {"value" : 100, "decaying" : true, "increasing" : false},
	"social" : {"value" : 100, "decaying" : true, "increasing" : false},
	#Hidden bad stats
	"stress" : {"value" : 0, "decaying" : true, "increasing" : false},
	"fatigue" : {"value": 0, "decaying" : true, "increasing" : false},
}

var multipliers = {
	"hunger" : {"decay_speed" : 0.007, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
	"energy" : {"decay_speed" : 0.007, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 0.5, "gain_multiplier" : 1.0},
	"fun" : {"decay_speed" : 0.007, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0,"gain_speed" : 1.0, "gain_multiplier" : 1.0},
	#Hidden stats
	"poop_level" : {"decay_speed" : 0.01, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
	"hygiene" : {"decay_speed" : 0.003, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
	"social" : {"decay_speed" : 0.002, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
	#Hidden bad stats
	"stress" : {"decay_speed" : 0.01, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
	"fatigue" : {"decay_speed" : 0.01, "pers_multiplier" : 1.0, "decay_multiplier" : 1.0, "gain_speed" : 1.0, "gain_multiplier" : 1.0},
}



##Long term stats
var love = 0
var love_max = 50


##Personality stats
#To be created... Just a few strings, dogmanager will initialize the stats properly UwU


func _ready():
	TimeManager.time_updated.connect(_on_time_updated)
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	
	target_position = position
	set_process_input(true)

	sprite.animation = "idle"
	last_position = position
	
	emit_signal("stats_updated", decay_stats, love)	#TODO: Remove parameters in favor of DogManager

var stuck_timer = 0

func _physics_process(delta):
	if position.distance_to(target_position) > 50 and can_move:
		target_vector = (target_position - position).normalized()
		velocity = target_vector * move_speed
	else: 
		velocity = Vector2.ZERO
	
	#Dumb collision workaround
	if position.distance_to(last_position) < 4 and position.distance_to(target_position) > 10:
		#Doggie is stuuckkkk!!
		stuck_timer += delta
	else:
		stuck_timer = 0

	if stuck_timer > 0.5:
		#Doggie gives up!
		velocity = Vector2.ZERO
		target_position = position
		stuck_timer = 0
	
	#print(velocity)
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0
	
	last_position = position
	move_and_slide() #We need to find a better system for this...
	

func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		call_doggie()

func call_doggie():
	#TODO: play a little click animation on the ground uwu - BUT NOT IN THIS SCRIPT!
	#TODO: if discipline is high - always respond. if low, might take multiple clicks.
		#if mood is disobedient, always ignore.
	tween_bounce()
	target_position = get_global_mouse_position()

func pet_dog():
	#TODO: ALL of this will be replaced by proper petting mechanics as in the bubble game <3
			
	tween_bounce()
	if love < love_max:
		love += 1
		emit_signal("stats_updated", decay_stats, love) #TODO: Remove parameters in favor of DogManager
		emit_signal("stat_increased", "love")

##TIME STUFF
func _on_time_updated(time_passed):
	if time_passed > (60 * 5):
		handle_long_awaytime()
	#No else statement yet cause I don't know how to handle the long awaytime lamayo
	
	for key in decay_stats:
		var stat = decay_stats[key] #opens the stat dictionary
		if stat["decaying"]:
			var decay_amount = -((multipliers[key]["pers_multiplier"] + multipliers[key]["decay_multiplier"]) / 2) * multipliers[key]["decay_speed"]
			set_stat(key, time_passed * decay_amount)
				
				
	#TODO: stats always decay (decaying = true), this will change based on state machines so they dont get tired while eating etc :3
	emit_signal("stats_updated", decay_stats, love)	#TODO: Remove parameters in favor of DogManager


func handle_long_awaytime():
	#Logic for how to update stats if the player has been gone a long time.
	#Energy will go up if the player has been gone for more than 30 minutes, but slower than its decrease rate.
	pass

func _on_tick_timer_timeout():
	for key in decay_stats:
		if decay_stats[key]["increasing"]:
			print("increasing: " + key)
			var gain_amount = (multipliers[key]["gain_multiplier"]) * multipliers[key]["gain_speed"]
			set_stat(key, gain_amount)
			emit_signal("stat_increased", key)
	emit_signal("stats_updated", decay_stats, love)


func set_stat(stat_name: String, value):
	decay_stats[stat_name]["value"] += value
	decay_stats[stat_name]["value"] = clamp(decay_stats[stat_name]["value"], 0, 120)

func get_stat(stat_name : String):
	return decay_stats[stat_name]["value"]

func get_stat_type(stat_name : String, type):
	return decay_stats[stat_name]["value"]



##Petting logic
func _on_dog_button_pressed() -> void:
	pet_dog()


func tween_bounce():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)


##DEBUG BUTTONS
#TODO: Move debugging to the DogManager as well, and then the DogManager can talk to the DogScript, no? 
#Or I suppose it doesn't matter yet



func _on_debug_stats_debug_button_pressed(type: String, value: float) -> void:
	match type:
		"food":
			state_machine.request_state("eat")
		"walk":
			return
		"shower":
			return
		"play":
			return
		"hunger":
			set_stat("hunger", value)
		"fun":
			set_stat("fun", value)
		"energy":
			set_stat("energy", value)
		_:
			print("Nothing changed")
		
	print(get_stat("hunger"))
	emit_signal("stats_updated", decay_stats, love)
