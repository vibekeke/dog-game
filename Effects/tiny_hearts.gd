extends AnimatedSprite2D

@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = randf_range(0.5, 0.7)
	timer.start()
	
	var random_size = randf_range(0.09, 0.12)
	scale = Vector2(random_size, random_size)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var random_speed = randi_range(50, 200)
	self.position.y = move_toward(self.position.y, -1, random_speed * delta)

func _on_timer_timeout() -> void:
	queue_free()
