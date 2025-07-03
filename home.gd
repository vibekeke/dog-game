extends Node2D

var tiny_hearts = load("res://Effects/tiny_hearts.tscn")

var active_dogs = []
@onready var dog1 = $Dog
@onready var dog2 = $Dog2
@onready var dog3 = $Dog3
@onready var dog4 = $Dog4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	active_dogs = [dog1, dog2, dog3, dog4]	
	for dog in active_dogs:
		dog.stat_increased.connect(_on_dog_stat_increased)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#Spawns tiny hearts whenever love increases.
#This might be a bad system for it?
func _on_dog_stat_increased(dog, stat: String) -> void:
	if stat == "love":
		var random_amount = randi_range(2, 4) #Skal endre dette til en verdi typ love_amount ellerno...
		
		for i in randi_range(1, 3):
			await get_tree().create_timer(randf_range(0.0, 0.1)).timeout
			var tiny_hearts_instance = tiny_hearts.instantiate()
			var tiny_hearts_position = dog.global_position
			$EffectsLayer.add_child(tiny_hearts_instance)
			
			var randx = randi_range(-40, 40)
			var randy = randi_range(-70, -30)
			tiny_hearts_instance.global_position = tiny_hearts_position + Vector2(randx, randy)


func _on_debug_stats_hud_showerbutton_pressed() -> void:
	pass # Replace with function body.
