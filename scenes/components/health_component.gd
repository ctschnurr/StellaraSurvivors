extends Node
class_name HealthComponent

signal died(max_health)
signal hurt(current_health)

@onready var progress_bar = %ProgressBar

@export var animation_player: AnimationPlayer

@export var max_health: float = 10
var current_health
var vulnerable: bool = true

func _ready():
	current_health = max_health

func _process(_delta):
	progress_bar.global_position = Vector2(owner.global_position.x - 25, owner.global_position.y + 25)
	
	
# Called when the node enters the scene tree for the first time.
func damage(damage_amount: float):
	if vulnerable:
		vulnerable = false
		current_health = max(current_health - damage_amount, 0)
		hurt.emit(current_health)
		Callable(check_death).call_deferred()
		
		
func check_death():
		if current_health == 0:
			if progress_bar.visible: progress_bar.visible = false
			#animation_player.play("Death")
			#await animation_player.animation_finished
			died.emit(max_health)
			#owner.queue_free()
			
		else:
			#animation_player.play("Damage")
			#await animation_player.animation_finished
			if !progress_bar.visible: progress_bar.visible = true
			var percent = current_health / max_health
			progress_bar.value = percent
			await get_tree().create_timer(0.15).timeout
			vulnerable = true
