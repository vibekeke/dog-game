extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var tick_timer = $TickTimer
@onready var state_machine = $StateMachine


@export var dog_name : String = "Dog"

var move_speed = 300
var move_multiplier = 1.0 #should be affected by moods and personality UwU

var target_position = Vector2()
var target_vector = Vector2()
var sceen_size

var can_move = true
var can_pet = true
var can_sleep = true
var can_eat = true

var last_position = Vector2()

var stat_max = 120

signal stats_updated(dog) #TODO: HUD will fetch stats from DogManager, not the dog script!
signal stat_increased(dog, stat: String) #For visual effects purposes (EffectsLayer!)
signal stat_decreased(dog, stat: String) #For visual effects purposes (EffectsLayer!)

#TODO: increasing and gain_speed variables are redundant and unnecessary.
var needs = {
	"hunger" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.007,
		"base_decay_rate" : 0.007,
		"increasing" : false,
		"gain_rate" : 2,
		"base_gain_rate" : 2
	},
	"energy" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.007,
		"base_decay_rate" : 0.007,
		"increasing" : false,
		"gain_rate" : 1,
		"base_gain_rate" : 1},
	"fun" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.007,
		"base_decay_rate" : 0.007,
		"increasing" : false,
		"gain_rate" : 0,
		"base_gain_rate" : 0},
	#Hidden  stats
	"poop_level" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.01,
		"base_decay_rate" : 0.01,
		"increasing" : false,
		"gain_rate" : 0,
		"base_gain_rate" : 0
		},
	"hygiene" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.003,
		"base_decay_rate" : 0.003,
		"increasing" : false,
		"gain_rate" : 0,
		"base_gain_rate" : 0
		},
	#Hidden bad stats (low = good)
	"stress" : {
		"value" : 70, 
		"decaying" : true, 
		"decay_rate" : 0.01,
		"base_decay_rate" : 0.01,
		"increasing" : false,
		"gain_rate" : 0,
		"base_gain_rate" : 0},
}

##Long term stats
var love = 0
var love_max = 50


##Personality stats
#To be created... Just a few strings, dogmanager will initialize the stats properly UwU


func _ready():
	set_process_input(true)
	TimeManager.time_updated.connect(_on_time_updated)
	tick_timer.timeout.connect(_on_tick_timer_timeout)
	
	target_position = position
	last_position = position

	sprite.animation = "idle"
	
	frequent_poop_rate()
	
	emit_signal("stats_updated", self)	#TODO: Remove parameters in favor of DogManager

var stuck_timer = 0

func frequent_poop_rate():
	#for youtube shorts! :3
	var rand = randi_range(50, 80)
	set_stat("poop_level", rand)
	needs["poop_level"]["decay_speed"] = rand / 40

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
		emit_signal("stats_updated", self) #TODO: Remove parameters in favor of DogManager
		emit_signal("stat_increased", self, "love")

##TIME STUFF
func _on_time_updated(time_passed):
	if time_passed > (60 * 5):
		handle_long_awaytime()
	#No else statement yet cause I don't know how to handle the long awaytime lamayo
	
	for key in needs:
		var stat = needs[key] #opens the stat dictionary
		if stat["decaying"]:
			change_stat(key, - time_passed * needs[key]["decay_rate"])
		if needs[key]["increasing"]:
			change_stat(key, time_passed * needs[key]["gain_rate"])
			emit_signal("stat_increased",self, key)
	
	#TODO: stats always decay (decaying = true), this will change based on state machines so they dont get tired while eating etc :3
	emit_signal("stats_updated", self)	#TODO: Remove parameters in favor of DogManager


func handle_long_awaytime():
	#Logic for how to update stats if the player has been gone a long time.
	#Energy will go up if the player has been gone for more than 30 minutes, but slower than its decrease rate.
	pass

func _on_tick_timer_timeout():
	#Dunno if there should really be stuff in here or if it should all be handled elsewhere.
	pass


func set_stat(stat_name: String, value):
	needs[stat_name]["value"] = value
	needs[stat_name]["value"] = clamp(needs[stat_name]["value"], 0, 120)
	
func change_stat(stat_name: String, value):
	needs[stat_name]["value"] += value
	needs[stat_name]["value"] = clamp(needs[stat_name]["value"], 0, 120)

func get_stat(stat_name : String):
	return needs[stat_name]["value"]


##Petting logic
func _on_dog_button_pressed() -> void:
	pet_dog()


func tween_bounce():
	var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)


func poop():
	tween_bounce()
	change_stat("poop_level", 100)
	
	#TODO: Could create a spawn point for the poop later, but this is ok
	var random_x = randi_range(-10, 10)
	var random_y = randi_range(-10, 10)
	
	var poop_position = position + Vector2(random_x, random_y)
	
	if sprite.flip_h:
		poop_position +=  Vector2(-80, 5)
	else:
		poop_position += Vector2(80, 5)
	
	var poop = preload("res://Dogs/poop.tscn").instantiate()
	poop.global_position = poop_position
	get_tree().current_scene.add_child(poop)
	poop.add_to_group("poop")


##DEBUG BUTTONS
#TODO: Move debugging to the DogManager as well, and then the DogManager can talk to the DogScript, no? 
#Or I suppose it doesn't matter yet



func _on_debug_stats_debug_button_pressed(type: String, value: float) -> void:
	match type:
		"food":
			state_machine.request_state("goto_food")
		"walk":
			return
		"shower":
			return
		"play":
			return
		"hunger":
			change_stat("hunger", value)
		"fun":
			change_stat("fun", value)
		"energy":
			change_stat("energy", value)
		_:
			print("Nothing changed")
		
	emit_signal("stats_updated", self)
