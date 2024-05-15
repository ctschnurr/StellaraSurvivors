extends Node
class_name HealthComponent

signal died
signal hurt(current_health)

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
		hurt.emit(current_health)
		Callable(check_death).call_deferred()
		
		
func check_death():
		if current_health == 0:
			#animation_player.play("Death")
			#await animation_player.animation_finished
			died.emit()
			#owner.queue_free()
			
		else:
			#animation_player.play("Damage")
			#await animation_player.animation_finished
			vulnerable = true
