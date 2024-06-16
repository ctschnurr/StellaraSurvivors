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
		if owner is Player: vulnerable = false
		current_health = max(current_health - damage_amount, 0)
		hurt.emit(current_health)
		Callable(check_death).call_deferred()
		App.spawn_manager.spawn_status_effect_particles(damage_amount, Color.RED, owner.global_position)
		await get_tree().create_timer(0.25).timeout
		vulnerable = true
		
		
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
			update_health_bar()
			
			
func update_health_bar():
	if !progress_bar.visible && current_health < max_health: progress_bar.visible = true
	elif progress_bar.visible && current_health == max_health: progress_bar.visible = false
	var percent = current_health / max_health
	progress_bar.value = percent
	
	
func heal(heal_input):
	var heal_amount = heal_input
	var missing_health = max_health - current_health
	if heal_amount >= missing_health or heal_input == 0: 
		heal_amount = missing_health
		current_health = max_health
	else: current_health += heal_amount
	App.spawn_manager.spawn_status_effect_particles(heal_amount, Color.GREEN, owner.global_position)
	update_health_bar()
