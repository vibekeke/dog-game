class_name EatState
extends State

#ALL STATES NEED THESE:
var state_name = "eating"
@onready var dog = $"../.."
@onready var tick_timer = $"../..//TickTimer"
@onready var state_machine = $".."

var eat_timer
var currently_eating

#TODO: Stort oroblem med logikken: Det er et par måter en hund kan bli bedt om å gå
#ut av eat_state på, som at den er mett eller at food sier ifra at den er tom. 
#MEN, dersom hunden av en eller annen grunn kommer ut av rangen til maten på egenhånd
#så kommer den aldri til å få beskjed om at den ikke spiser lenger.
#Vi må registrere aktive mater, og så avregistrere de når de ikke er i nærheten. Dette
#må være robust, slik at hunden ikke misser dette - det burde vært OK men det er litt mange 
#avhengigheter så bare se på det oki?

func _ready():
	set_physics_process(false)
	eat_timer = Timer.new()
	eat_timer.wait_time = 2
	eat_timer.timeout.connect(_on_eat_timer_timeout)
	add_child(eat_timer)

func _enter_state() -> void:
	eat_timer.start()
	dog.can_move = false
	dog.can_eat = false #we dont want dog to go eat something else while already eating
	dog.can_sleep = false
	dog.decay_stats["hunger"]["decaying"] = false
	dog.decay_stats["hunger"]["increasing"] = true
	
	dog.multipliers["poop_level"]["decay_multiplier"] += 0.3
	
func _exit_state() -> void:
	eat_timer.stop()
	dog.can_move = true
	dog.can_eat = true
	dog.can_sleep = true
	dog.decay_stats["hunger"]["decaying"] = true
	dog.decay_stats["hunger"]["increasing"] = false
	
	dog.multipliers["poop_level"]["decay_multiplier"] -= 0.3
	#Will exit when finished eating, duhh.

func stop_eating():
	state_machine.request_state("idle")

func _on_eat_timer_timeout():
	if dog.get_stat("hunger") >= 120:
		state_machine.request_state("idle")
	if get_tree().get_nodes_in_group("food").size() < 1:
		state_machine.request_state("idle")
