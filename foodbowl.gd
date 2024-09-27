extends StaticBody2D

@onready var depletionTimer = $DepletionTimer
	
var bowl_fullness = 0

signal filled
signal emptied

func _ready() -> void:
	update_bowl_level()
	$BowlSprite2D.play()
	depletionTimer.wait_time = 1


func update_bowl_level():
	if bowl_fullness == 0:
		$BowlSprite2D.animation = "empty"
	if bowl_fullness > 0 and bowl_fullness < 5:
		$BowlSprite2D.animation = "half"
	if bowl_fullness > 5 and bowl_fullness <= 10:
		$BowlSprite2D.animation = "full"
	
func _on_hud_hud_foodbutton_pressed() -> void:
	bowl_fullness = 10
	print(bowl_fullness)
	update_bowl_level()
	var anchor_position = $BowlAnchorA.global_position
	emit_signal("filled", anchor_position)

func _on_dog_started_eating() -> void:
	print("Dog bowl entered!" + str(bowl_fullness))
	#Problem: Hvis hunden accidentally går inn i området
	update_eating_animation()
	depletionTimer.start()

func update_eating_animation():
	if bowl_fullness == 0:
		$BowlSprite2D.animation = "empty"
	if bowl_fullness in range(0, 5):
		$BowlSprite2D.animation = "half_animated"
	if bowl_fullness in range(5, 11):
		$BowlSprite2D.animation = "full_animated"

func _on_depletion_timer_timeout() -> void:
	if bowl_fullness > 0:
		bowl_fullness -= 1
		update_eating_animation()
		depletionTimer.start()
	else:
		emit_signal("emptied")
		update_bowl_level()
	
	print(bowl_fullness)
	
