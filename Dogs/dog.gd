extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

var move_speed = 300
var click_position = Vector2()
var target_vector = Vector2()
var sceen_size
var can_move = true
var last_position = Vector2()

signal pooped
signal stats_updated(decay_stats, love) #TODO: HUD will fetch stats from DogManager, not the dog script!
signal stat_increased(stat: String) #For visual effects purposes (EffectsLayer!)
signal stat_decreased(stat: String) #For visual effects purposes (EffectsLayer!)




var decay_stats = {
	"hunger" : {"value" : 70, "decay_speed" : 0.007, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	"energy" : {"value" : 70, "decay_speed" : 0.007, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	"fun" : {"value" : 70, "decay_speed" : 0.007, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	#Hidden rising stats
	"poop_level" : {"value" : 0, "decay_speed" : 0.01, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	"dirt" : {"value" : 0, "decay_speed" : 0.003, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	"loneliness" : {"value" : 0, "decay_speed" : 0.002, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	#Hidden bad stats
	"stress" : {"value" : 0, "decay_speed" : 0.01, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
	"annoyance" : {"value" : 0, "decay_speed" : 0.01, "pers_multiplier" : 1.0, "state_multiplier" : 1.0, "decaying" : true},
}

##Long term stats
var love = 0
var love_max = 50


##Personality stats
#To be created... Just a few strings, dogmanager will initialize the stats properly UwU


func _ready():
	TimeManager.time_updated.connect(_on_time_updated)
	click_position = position
	set_process_input(true)

	sprite.animation = "idle"
	last_position = position
	
	emit_signal("stats_updated", decay_stats, love)	#TODO: Remove parameters in favor of DogManager

var stuck_timer = 0

func _physics_process(delta):
	if position.distance_to(click_position) > 50 and can_move:
		target_vector = (click_position - position).normalized()
		velocity = target_vector * move_speed
	else: 
		velocity = Vector2.ZERO
	
	#Dumb collision workaround
	if position.distance_to(last_position) < 4 and position.distance_to(click_position) > 10:
		#Doggie is stuuckkkk!!
		stuck_timer += delta
	else:
		stuck_timer = 0

	if stuck_timer > 0.5:
		#Doggie gives up!
		velocity = Vector2.ZERO
		click_position = position
		stuck_timer = 0
	
	#print(velocity)
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0
	
	last_position = position
	move_and_slide() #We need to find a better system for this...
	

func tween_bounce():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)


func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click"):
		tween_bounce()
		click_position = get_global_mouse_position()


##TIME STUFF
func _on_time_updated(time_passed):
	if time_passed > (60 * 5):
		handle_long_awaytime()
	#No else statement yet cause I don't know how to handle the long awaytime lamayo
	
	for key in decay_stats:
		var stat = decay_stats[key] #opens the stat dictionary
		if stat["decaying"]:
			var decay_amount = -((stat["pers_multiplier"] + stat["state_multiplier"]) / 2) * stat["decay_speed"]
			set_stat(key, time_passed * decay_amount)
				
				
	#TODO: stats always decay (decaying = true), this will change based on state machines so they dont get tired while eating etc :3
	emit_signal("stats_updated", decay_stats, love)	#TODO: Remove parameters in favor of DogManager


func handle_long_awaytime():
	#Logic for how to update stats if the player has been gone a long time.
	pass

func set_stat(stat_name: String, value):
	decay_stats[stat_name]["value"] += value
	decay_stats[stat_name]["value"] = clamp(decay_stats[stat_name]["value"], 0, 120)

func get_stat(stat_name : String):
	return decay_stats[stat_name]["value"]






func _on_area_2d_area_entered(area: Area2D) -> void:
	#This will be inside of a state machine, tnx
	pass # Replace with function body.


##Petting logic
func _on_dog_button_pressed() -> void:
	#TODO: ALL of this will be replaced by proper petting mechanics as in the bubble game <3
			
	tween_bounce()
	if love < love_max:
		love += 1
		emit_signal("stats_updated", decay_stats, love) #TODO: Remove parameters in favor of DogManager
		emit_signal("stat_increased", "love")

##DEBUG BUTTONS
#TODO: Move debugging to the DogManager as well, and then the DogManager can talk to the DogScript, no? 
#Or I suppose it doesn't matter yet



func _on_debug_stats_debug_button_pressed(type: String, value: float) -> void:
	match type:
		"food":
			return
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
