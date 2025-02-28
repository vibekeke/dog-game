extends CanvasLayer

@onready var love_label = $LoveLabel
@onready var hunger_bar = $Controls/HungerBar
var heart_size = 0.25
var love_ismax = false


signal HUD_foodbutton_pressed
signal HUD_walkbutton_pressed
signal HUD_showerbutton_pressed
signal HUD_playbutton_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$LoveLabel.text = "0"
	$Heart.scale = Vector2(0.25, 0.25)



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


#TEMPORARY DEBUG BUTTONS - replace with real gameplay later lamayo
func _on_foodbutton_pressed() -> void:
	emit_signal("HUD_foodbutton_pressed")

func _on_walkbutton_pressed() -> void:
	emit_signal("HUD_walkbutton_pressed")

func _on_showerbutton_pressed() -> void:
	emit_signal("HUD_showerbutton_pressed")

func _on_playbutton_pressed() -> void:
	emit_signal("HUD_playbutton_pressed")
