extends CharacterBody2D


@onready var sprite = $AnimatedSprite2D
var move_speed = 300
var click_position = Vector2()
var direction_vector = Vector2()
var sceen_size
var can_move = true

signal pooped
signal stats_updated(love, hunger, energy, fun) #TODO: HUD will fetch stats from DogManager, not the dog script!
signal stat_increased(stat: String) #For visual effects purposes (EffectsLayer!)
signal stat_decreased(stat: String) #For visual effects purposes (EffectsLayer!)


##Long term stats
var love = 0
var love_max = 50

##Short term stats
var hunger = 70
var hunger_decay = 0.007
var energy = 70
var energy_decay = 0.006
var fun = 50
var fun_decay = 0.008

##Hidden stats
var stress = 0
var lonely = 0
var dirty = 0

var poop = 0

##Personality stats
#To be created... Just a few strings, dogmanager will initialize the stats properly UwU


func _ready():
	click_position = position
	set_process_input(true)
	
	TimeManager.time_updated.connect(_on_time_updated)
	
	emit_signal("stats_updated", love, hunger, energy, fun)	#TODO: Remove parameters in favor of DogManager


func _physics_process(delta):
	if position.distance_to(click_position) > 50:
		direction_vector = (click_position - position).normalized()
		velocity = direction_vector * move_speed
		move_and_slide() #We need to find a better system for this...
	
	if velocity.x != 0:
		sprite.animation = "idle"
		sprite.flip_h = velocity.x > 0
	
	#TODO: Make a tween function you filthy animal!
	sprite.scale.x = move_toward(sprite.scale.x, 1, 2 * delta)
	sprite.scale.y = move_toward(sprite.scale.x, 1, 2 * delta)


func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click") and can_move == true:
		sprite.scale = Vector2(1.2, 0.8)
		click_position = get_global_mouse_position()


##TIME STUFF
func _on_time_updated(time_passed):
	if time_passed > (60 * 5):
		handle_long_awaytime()
	
	
	#TODO: For now it always decays, this will change based on state machines so they dont get tired while eating etc :3
	print("Stats changed! " + str(time_passed))
	hunger -= time_passed * hunger_decay
	hunger = clamp(hunger, 0, 110)
	
	energy -= time_passed * energy_decay
	energy = clamp(energy, 0, 110) 
	
	fun -= time_passed * fun_decay
	fun = clamp(fun, 0, 110) 
	
	print("hunger " + str(hunger))
	emit_signal("stats_updated", love, hunger, energy, fun)	#TODO: Remove parameters in favor of DogManager


func handle_long_awaytime():
	#Logic for how to update stats if the player has been gone a long time.
	pass



func _on_area_2d_area_entered(area: Area2D) -> void:
	#This will be inside of a state machine, tnx
	pass # Replace with function body.


##Petting logic
func _on_dog_button_pressed() -> void:
	#TODO: ALL of this will be replaced by proper petting mechanics as in the bubble game <3
	if love < love_max:
		love += 1
		emit_signal("stats_updated", love, hunger, energy, fun) #TODO: Remove parameters in favor of DogManager
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
			hunger += value
		"fun":
			fun += value
		"energy":
			energy += value
		_:
			print("Nothing changed")
	emit_signal("stats_updated", love, hunger, energy, fun)
