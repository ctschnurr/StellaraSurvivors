extends Node
class_name HealthComponent

signal died

@export var animation_player: AnimationPlayer

@export var max_health: float = 10
var current_health
var vulnerable: bool = true

func _ready():
	current_health = max_health

	
# Called when the node enters the scene tree for the first time.
func damage(damage_amount: float):
	if vulnerable:
		vulnerable = false
		current_health = max(current_health - damage_amount, 0)
		Callable(check_death).call_deferred()
		
		
func check_death():
		if current_health == 0:
			animation_player.play("Death")
			await animation_player.animation_finished
			owner.queue_free()
			
		else:
			animation_player.set_current_animation("Damage")
			await animation_player.animation_finished
			vulnerable = true
