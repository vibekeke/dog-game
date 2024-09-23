extends Node2D

signal poop_cleaned

func _ready() -> void:
	$AnimatedPoop2D.play()

func _on_button_pressed() -> void:
	queue_free()
