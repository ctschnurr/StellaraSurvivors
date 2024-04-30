extends Node
class_name HealthComponent

signal died

@export var animation_player: AnimationPlayer

@export var max_health: float = 10
var current_health


func _ready():
	current_health = max_health
		
		
func free_me():
	owner.queue_free()
	
# Called when the node enters the scene tree for the first time.
func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	Callable(check_death).call_deferred()
		
		
func check_death():
		if current_health == 0:
			animation_player.set_current_animation("Death")
			animation_player.play
			
			died.emit()
		else:
			animation_player.set_current_animation("Damage")
			animation_player.play
