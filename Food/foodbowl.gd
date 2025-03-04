extends StaticBody2D

@onready var check_timer = $CheckTimer
@export var bowl_name : String

var bowl_fullness = 0
var bowl_filled = false
var bowl_health = 10
var depletion_speed = 1

var current_state : String

var registered_dogs = []
var eating_dogs = [] #find a better variable name

signal food_entered(food, dog)

func _ready() -> void:
	update_still_animation()
	$BowlSprite2D.play()
	
	FoodManager.fill_bowl_requested.connect(fill_bowl)	#TODO: This will obviously be changed.



func fill_bowl() -> void:
	bowl_fullness = 7
	state_full()
	check_eating_dogs()
	FoodManager.register_food(self)
	for dog in registered_dogs:
		emit_signal("food_entered", self, dog)

func state_full():
	current_state = "filled_bowl"
	check_timer.start()
	update_still_animation()
	
func state_empty():
	check_timer.stop()
	
	print("bowl emptied")
	current_state = "empty_bowl"
	for dog in eating_dogs:
		dog.state_machine.request_state("reset")
	eating_dogs.clear()
	
	update_still_animation()
	FoodManager.deregister_food(self)



func _on_check_timer_timeout() -> void:
	print("Bowl " + bowl_name + ": " + current_state)
	check_eating_dogs()

func check_eating_dogs():
	eating_dogs = eating_dogs.filter(func(dog): return dog.state_machine.current_state == EatState)
	
	for dog in registered_dogs:
		if dog.state_machine.current_state is EatState and dog not in eating_dogs:
			eating_dogs.append(dog)
		else:
			emit_signal("food_entered", self, dog)
	
	if eating_dogs.size() > 0:
		current_state = "depleting_bowl"
		depletion_speed = eating_dogs.size()
		state_deplete_food()
	else:
		current_state = "filled_bowl"
		update_still_animation()
		check_timer.wait_time = 1
		
		

func state_deplete_food():
	if bowl_fullness > 0:
		bowl_fullness -= depletion_speed
		
	if bowl_fullness > 0:
		eating_animation()
	else:
		bowl_fullness = 0
		state_empty()



##------REFACTOR-----

	

func _on_area_2d_area_entered(area: Area2D) -> void:
	var dog = area.get_parent()
	registered_dogs.append(area.get_parent())
	emit_signal("food_entered", self, dog) #DETTE VAR PROBLEMET ALL ALONG. Hundene vet ikke HVEM som entered.
	

func _on_area_2d_area_exited(area: Area2D) -> void:
	var dog = area.get_parent()
	registered_dogs.erase(dog)
	if dog in eating_dogs:
		eating_dogs.erase(dog)
		dog.state_machine.request_state("reset")





func update_still_animation():
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
	
