extends Node2D

var tiny_hearts = load("res://tiny_hearts.tscn")
var poop = load("res://poop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#LOVE STATS
func _on_dog_love_changed_home(love, love_ismax, increased) -> void:
	var random_amount = randi_range(2, 4) #Skal endre dette til en verdi typ love_amount ellerno...
	
	if love_ismax == false and increased == true:
		for i in randi_range(1, 3):
			var tiny_hearts_instance = tiny_hearts.instantiate()
			var tiny_hearts_position = $Dog.global_position
			$EffectsLayer.add_child(tiny_hearts_instance)
			
			var randx = randi_range(-40, 40)
			var randy = randi_range(-70, -30)
			tiny_hearts_instance.global_position = tiny_hearts_position + Vector2(randx, randy)

#POOPING
func _on_dog_time_to_poop() -> void:
	print("Should have pooped!")
	var poop_instance = poop.instantiate()
	var poop_position = $Dog.global_position + Vector2(0, -20) #Might have to get the dog somehow
	var poop_direction = $Dog/AnimatedSprite2D.flip_h
	
	if poop_direction == false:
		poop_position += Vector2(80, -10)
	else:
		poop_position -= Vector2(80, 10)
	
	self.add_child(poop_instance)
	poop_instance.global_position = poop_position
