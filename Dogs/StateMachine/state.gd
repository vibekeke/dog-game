class_name State
extends Node

signal state_finished


#ALL STATES NEED THESE:
#var state_name
#@onready var dog
#@onready var tick_timer
#@onready var state_machine


func _enter_state() -> void:
	pass
	
func _exit_state() -> void:
	pass
