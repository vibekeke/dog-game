extends CanvasLayer

@onready var love_label = $LoveLabel
@onready var hunger_bar = $Controls/HungerBar
@onready var home = $".."	#Just for testing
var heart_size = 0.25

@onready var dog1 = $"../Dog"
@onready var dog2 = $"../Dog2"
@onready var dog3 = $"../Dog3"
@onready var dog4 = $"../Dog4"

var active_dogs = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LoveLabel.text = "0"
	$Heart.scale = Vector2(0.25, 0.25)
	
	##Now all the dogs are connected to the same hud, which might look strange but is good for youtube shorts
	active_dogs = [dog1, dog2, dog3, dog4]	
	for dog in active_dogs:
		print("dog in home")
		dog.stats_updated.connect(_on_dog_stats_updated)


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



func _on_dog_stats_updated(dog) -> void:
	#We need to send all the stats
	#Might be complicated with all the dogs...
	$LoveLabel.text = str(dog.love)

	if dog.love > 50:
		$LoveLabel.text = "MAX"
		$Heart.scale = Vector2(0.5, 0.5)

	$Controls/HungerBar.value = dog.decay_stats["hunger"]["value"]
	$Controls/EnergyBar.value = dog.decay_stats["energy"]["value"]
	$Controls/FunBar.value = dog.decay_stats["fun"]["value"]
