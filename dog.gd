extends CharacterBody2D

@onready var idleTimer = $IdleTimer
#Movement variables
var speed = 300
var click_position = Vector2()
var direction_vector = Vector2()
var screen_size
var standing_still = true
var increased = false
var move_enabled = true

var dog_mode = "Home"
var dog_state = "Idle"
var mood = "Neutral"

signal love_changed(love, love_ismax, increased)
signal hunger_changed(hunger)
signal energy_changed(energy)
signal fun_changed(fun)
signal time_to_poop()
signal started_eating()


#TIME BASED-STATS
var love = 0
var petting_counter = 0
var hunger = 70		#Get this value from autoload probably? Like onready var
var energy = 80
var fun = 50
var stress = 0
var dirty = 0
var need_to_poop = 0

func _ready():
	click_position = position
	set_process_input(true)
	emit_all_stats()

func _unhandled_input(event):
	if Input.is_action_just_pressed("left_click") and move_enabled == true:
		$AnimatedSprite2D.scale = Vector2(1.2, 0.8)
		click_position = get_global_mouse_position()
		
		if dog_state == "Idle":
			idleTimer.wait_time = randi_range(3, 5)
			idleTimer.start()
		

func _physics_process(delta):
	if position.distance_to(click_position) > 50:
		direction_vector = (click_position - position).normalized()
		velocity = direction_vector * speed
		move_and_slide() #We need to find a better system for this...
		
	if velocity.x != 0 and dog_state != "Eating":
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.flip_h = velocity.x > 0
		
	$AnimatedSprite2D.scale.x = move_toward($AnimatedSprite2D.scale.x, 1, 2 * delta)
	$AnimatedSprite2D.scale.y = move_toward($AnimatedSprite2D.scale.x, 1, 2 * delta)
		
	'''
		#If COOKIE ON SCREEN:
			target_position = (click_position - cookie.position).normalized()
			velocity = target_position * speed
			move_and_slide()
			...Når hunden collider med cookie så blir den spist. Hvis hunden er mett må vi gjøre mere greier lol
		'''

func _on_idle_timer_timeout() -> void:
	if dog_state == "Idle" or dog_state == "FallingAsleep":
		var random_x = randi_range(-230, 230)
		var random_y = randi_range(-300, 300)
		var min_distance = 80
		
		#We want random movement, but not teeny tiny baby steps:
		if abs(random_x) < min_distance:
			if random_x >= 0:
				random_x = min_distance
			else:
				random_x = -min_distance

		if abs(random_y) < min_distance:
			if random_y >= 0:
				random_y = min_distance
			else:
				random_y = -min_distance

		var new_x = clamp(global_position.x + random_x, 100, 480)
		var new_y = clamp(global_position.y + random_y, 200, 800)
		
		var random_time = randi_range(2, 5)
		print("Moving on x by" +  str(random_x))
		print("Moving on y by" +  str(random_y))
		click_position = Vector2(new_x, new_y)
		idleTimer.wait_time = random_time
		idleTimer.one_shot = true
		idleTimer.start()
		print("The current timer is set to " + str(random_time))

#STAT CHANGES
func emit_all_stats():
	emit_signal("love_changed", love, love_ismax, increased)
	emit_signal("hunger_changed", hunger)
	emit_signal("energy_changed", energy)
	emit_signal("fun_changed", fun)
	#These might be merged into a single "stats_changed" thing later, but it might be useful to keep them separate. We will see.
	
	update_states_and_moods()

#Love is getting an extra function because it is such an important variable uwu
func love_update():
	if love > love_max:
		love_ismax = true
	else:
		love_ismax = false
	emit_signal("love_changed", love, love_ismax, increased)


#Changing the state and updating animation + key variables.
func change_state(new_state):
	dog_state = new_state
	if dog_state == "Sleeping":
		$AnimatedSprite2D.flip_v = true
		move_enabled = false
	if dog_state == "FallingAsleep":
		move_enabled = true
	if dog_state == "Idle":
		$AnimatedSprite2D.flip_v = false
		move_enabled = true
	if dog_state == "WantsToEat":
		move_enabled = false
	if dog_state == "Eating":
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = false
		move_enabled = false

''' This function only handles change between states, i.e. going from eating to sleeping.
Any changes in stats that result must be handled elsewhere!!'''
func update_states_and_moods():
	print("Current state is " + dog_state)
	
	if energy == 0:
		print("The dog passed out!")
		change_state("Sleeping")
		wake_countdown = randi_range(10, 20)
	
	if energy < 20 and dog_state == "Idle": #Vi adder også en variabel for inaktivitet hos spilleren
		print("Dog is falling asleep!")
		change_state("FallingAsleep")
		sleep_countdown = randi_range(5, 10)
	
	if dog_state == "FallingAsleep":
		print("Time to sleep: " + str(sleep_countdown))
		sleep_countdown -= 1

	if dog_state == "FallingAsleep" and sleep_countdown == 0:
		print("Dog is asleep!")
		change_state("Sleeping")
		wake_countdown = randi_range(10, 50)

#STAT MANAGEMENT
var love_power = 1 #Number between 1 and 3: 1 is a normal amount, 2 is a lot of love, and 3 is super-love.
var love_decayspeed = 1
var love_minimum = 25 	#I imagine this stat can be updated so you won't lose all progress :) 
var love_max = 50		#I imagine this stat will be updated so you can provide EVEN MORE LOVE!!
var love_ismax = false
var love_level = 0 		#Level updates when love has been max for a while

var petting_power = 1

var hunger_decayspeed = 2
var energy_decayspeed = 1
var sleep_countdown = 0
var wake_countdown = 0

var fun_decayspeed = 3

var stress_decayspeed = 1

var poop_max = 20


#Conditions stat decreases:
func _on_stats_timer_timeout() -> void:
	update_stats_on_timer()
	update_states_and_moods()

'''For eksempel når støvsuger i nærheten av hund etc.'''

#Initating stat decreases
func update_stats_on_timer() -> void:
	increased = false
	if love > love_minimum:
		love -= love_decayspeed
		love_update()
	
	#Petting cooldown
	if petting_counter > 0:
		petting_counter -= 1
	
	#Hunger
	if hunger > 0:
		hunger -= hunger_decayspeed
		emit_signal("hunger_changed", hunger)
	
	#Energy
	if energy > 0 and dog_state != "Sleeping":
		energy -= energy_decayspeed
		emit_signal("energy_changed", energy)

	if energy < 100 and dog_state == "Sleeping":
		energy += 3
		emit_signal("energy_changed", energy)
	
	#Fun
	if fun > 0:
		fun -= fun_decayspeed
		emit_signal("fun_changed", fun)


#Initiating stat increases :D
func love_increase(amount):
	increased = true
	if love < (love_max + 10):
		love += amount
	love_update()


func _on_button_pressed() -> void:
	$AnimatedSprite2D.scale = Vector2(1.2, 0.9)
	if petting_counter <= 15:
		petting_counter += 1
		if petting_counter <= 10:
			love_increase(petting_power)

'''
func _on_hud_hud_foodbutton_pressed() -> void:
	if hunger < 130: 
		change_state("Idle")
		$AnimatedSprite2D.scale = Vector2(1.2, 0.8)
		hunger += 10
		need_to_poop += 3
		love_increase(5) #Should probably be a variable so we can add personality multiplyers :3
	emit_signal("hunger_changed", hunger)
'''

func _on_hud_hud_walkbutton_pressed() -> void:
	if energy > 30:
		change_state("Idle")
		$AnimatedSprite2D.scale = Vector2(1.2, 0.8)
		energy -= 30
		fun += 20
		need_to_poop = 0
		emit_signal("energy_changed", energy)
		emit_signal("fun_changed", fun)
		love_increase(10)
	else:
		print("Energy too low for a walk!")

func _on_hud_hud_playbutton_pressed() -> void:
	print("play button pressed")
	if fun < 150 and energy > 20:
		change_state("Idle")
		$AnimatedSprite2D.scale = Vector2(1.2, 0.8)
		fun += 10
		energy -= 10
		love_increase(10)
	emit_signal("energy_changed", energy)
	emit_signal("fun_changed", fun)
	
	
#POOPING
func _on_poop_timer_timeout() -> void:
	if need_to_poop >= poop_max and dog_state != "Sleeping":
		$AnimatedSprite2D.scale = Vector2(1, 1)
		emit_signal("time_to_poop")
		need_to_poop = 0
	else:
		need_to_poop += 1

#States and moods
#Conditions for stats and moods

func _on_food_bowl_filled(position) -> void:
	if hunger < 100 and dog_state == "Idle":
		print("The dog wants the food!")
		click_position = position
		change_state("WantsToEat")

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Started eating!")
	change_state("Eating")
	emit_signal("started_eating")
