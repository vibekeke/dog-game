extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var random_speed = randi_range(80, 100)
	self.position.y = move_toward(self.position.y, -1, random_speed * delta)

func _on_timer_timeout() -> void:
	queue_free()
