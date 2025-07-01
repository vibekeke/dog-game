extends CanvasLayer


signal debug_button_pressed(type : String, value : float)

@onready var bowl1 = $"../FoodBowl"
@onready var bowl2 = $"../FoodBowl2"


#To test functionality - foodbowl etc.
func _on_foodbutton_pressed() -> void:
	bowl1.fill_bowl()
	bowl2.fill_bowl()
	emit_signal("debug_button_pressed", "food", 0)

func _on_walkbutton_pressed() -> void:
	emit_signal("debug_button_pressed", "walk", 0)

func _on_showerbutton_pressed() -> void:
	emit_signal("debug_button_pressed", "shower", 0)

func _on_playbutton_pressed() -> void:
	emit_signal("debug_button_pressed", "play", 0)
	
	

#To test stat changes
func _on_add_hunger_pressed() -> void:
	emit_signal("debug_button_pressed", "hunger", 15)

func _on_remove_hunger_pressed() -> void:
	emit_signal("debug_button_pressed", "hunger", -15)
	
func _on_add_fun_pressed() -> void:
	emit_signal("debug_button_pressed", "fun", 15)

func _on_remove_fun_pressed() -> void:
	emit_signal("debug_button_pressed", "fun", -15)

func _on_add_energy_pressed() -> void:
	emit_signal("debug_button_pressed", "energy", 15)
	
func _on_remove_energy_pressed() -> void:
	emit_signal("debug_button_pressed", "energy", -15)




func _on_time_1m_pressed() -> void:
	TimeManager.debug_time_changed(60)

func _on_time_5m_pressed() -> void:
	TimeManager.debug_time_changed(60 * 5)

func _on_time_30m_pressed() -> void:
	TimeManager.debug_time_changed(60 * 30)

func _on_time_1h_pressed() -> void:
	TimeManager.debug_time_changed(60 * 60)
