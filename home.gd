extends Node2D

var tiny_hearts = load("res://Effects/tiny_hearts.tscn")
var poop = load("res://Dogs/poop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



#POOPING
func _on_dog_time_to_poop() -> void:
	print("Should have pooped!")
	var random_x = randi_range(-10, 10)
	var random_y = randi_range(-10, 10)
	var poop_instance = poop.instantiate()
	var poop_position = $Dog.global_position + Vector2(random_x, random_y) #Might have to get the dog somehow
	var poop_direction = $Dog/AnimatedSprite2D.flip_h
	
	if poop_direction == false:
		poop_position += Vector2(80, -10)
	else:
		poop_position -= Vector2(80, 10)
	
	self.add_child(poop_instance)
	poop_instance.global_position = poop_position



#Spawns tiny hearts whenever love increases.
#This might be a bad system for it?
func _on_dog_stat_increased(stat: String) -> void:
	if stat == "love":
		var random_amount = randi_range(2, 4) #Skal endre dette til en verdi typ love_amount ellerno...
		
		for i in randi_range(1, 3):
			await get_tree().create_timer(randf_range(0.0, 0.1)).timeout
			var tiny_hearts_instance = tiny_hearts.instantiate()
			var tiny_hearts_position = $Dog.global_position
			$EffectsLayer.add_child(tiny_hearts_instance)
			
			var randx = randi_range(-40, 40)
			var randy = randi_range(-70, -30)
			tiny_hearts_instance.global_position = tiny_hearts_position + Vector2(randx, randy)


func _on_debug_stats_hud_showerbutton_pressed() -> void:
	pass # Replace with function body.
