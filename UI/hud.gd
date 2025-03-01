extends CanvasLayer

@onready var love_label = $LoveLabel
@onready var hunger_bar = $Controls/HungerBar
var heart_size = 0.25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LoveLabel.text = "0"
	$Heart.scale = Vector2(0.25, 0.25)


'''
#When dog-script emits signal ("love_changed", love, love_ismax):
func _on_dog_love_changed_HUD(love, love_ismax, increased) -> void:
	$LoveLabel.text = str(love)

	if increased and love_ismax == false: 
		heart_size += 0.01
		$Heart.scale = Vector2(heart_size, heart_size)
	
	if love_ismax == true:
		$LoveLabel.text = "MAX"
		$Heart.scale = Vector2(0.5, 0.5)


func _on_dog_hunger_changed(hunger: int) -> void:
	$Controls/HungerBar.value = int(hunger)


func _on_dog_energy_changed(energy: Variant) -> void:
	$Controls/EnergyBar.value = int(energy)

func _on_dog_fun_changed(fun: Variant) -> void:
	$Controls/FunBar.value = int(fun)

'''



func _on_dog_stats_updated(love, hunger, energy, fun) -> void:
	#We need to send all the stats
	#Might be complicated with all the dogs...
	print("HUD updated")
	$LoveLabel.text = str(love)

	if love > 50:
		$LoveLabel.text = "MAX"
		$Heart.scale = Vector2(0.5, 0.5)

	$Controls/HungerBar.value = int(hunger)
	$Controls/EnergyBar.value = int(energy)
	$Controls/FunBar.value = int(fun)
