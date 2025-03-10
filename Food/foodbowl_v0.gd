extends StaticBody2D

@onready var depletion_timer = $DepletionTimer
	
var bowl_fullness = 0
var bowl_filled = false
var bowl_health = 10
var depletion_speed = 0


var registered_dogs = []
var eating_dogs = [] #find a better variable name

signal food_entered

func _ready() -> void:
	update_bowl_animation()
	$BowlSprite2D.play()
	
	FoodManager.fill_bowl_requested.connect(fill_bowl)	#TODO: This will obviously be changed.


func fill_bowl() -> void:
	bowl_fullness = 10
	update_bowl_animation()
	FoodManager.register_food(self)
	if eating_dogs.size() > 0:
		state_deplete_food()
	#var anchor_position = $BowlAnchorA.global_position
	#emit_signal("filled", anchor_position)

#func _on_dog_started_eating() -> void:
	#print("Dog bowl entered!" + str(bowl_fullness))
	##Problem: Hvis hunden accidentally går inn i området
	#update_eating_animation()
	#depletionTimer.start()

func _on_depletion_timer_timeout() -> void:
	state_deplete_food()
	check_eating_dogs()

func state_deplete_food():
	if bowl_fullness > 0:
		bowl_fullness -= 1
		eating_animation()
		depletion_timer.start()
	else:
		state_bowl_empty()

func state_bowl_empty():
	for dog in eating_dogs:
		dog.state_machine.request_state("idle")
		
		update_bowl_animation()
		FoodManager.deregister_food(self)
		depletion_timer.stop()


func check_eating_dogs():
	eating_dogs = eating_dogs.filter(func(dog): return dog.state_machine.current_state == EatState)
	
	for dog in registered_dogs:
		if dog.state_machine.current_state == EatState and dog not in eating_dogs:
			eating_dogs.append(dog)
	
	if eating_dogs.size() > 0:
		depletion_timer.wait_time = 1 / eating_dogs.size()
	else:
		depletion_timer.wait_time = 1
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().state_machine.current_state is GotoFoodState:
		print("Dog is eligible! Please refactor this code when it's not 4.am")
		##await area.get_parent().started_eating
		#I think this thing will be goooood
	state_deplete_food()
	register_dog(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	unregister_dog(area)


func unregister_dog(area: Area2D):
	eating_dogs.erase(area.get_parent())

func register_dog(area: Area2D):
	eating_dogs.append(area.get_parent()) #Adds the dog to the script












func update_bowl_animation():
	if bowl_fullness == 0:
		$BowlSprite2D.animation = "empty"
	if bowl_fullness > 0 and bowl_fullness < 5:
		$BowlSprite2D.animation = "half"
	if bowl_fullness > 5 and bowl_fullness <= 10:
		$BowlSprite2D.animation = "full"

func eating_animation():
	if bowl_fullness == 0:
		$BowlSprite2D.animation = "empty"
	if bowl_fullness in range(0, 5):
		$BowlSprite2D.animation = "half_animated"
	if bowl_fullness in range(5, 11):
		$BowlSprite2D.animation = "full_animated"
	
