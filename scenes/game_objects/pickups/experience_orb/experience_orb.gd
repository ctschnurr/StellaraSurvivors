class_name Experience_orb extends Pickup
@export var xp_amount: float = 1

signal collected(xp: float)

func _ready():
	super._ready()
	$Area2D.area_entered.connect(on_area_entered)
	
	
func on_area_entered(area_entered):
	collected.emit(xp_amount)
	SoundManager.play_sound(App.pickup_sound)
	App.spawn_manager.spawn_status_effect_particles(xp_amount, Color(0, 0.561, 0.984), area_entered.global_position)
	queue_free()
		
