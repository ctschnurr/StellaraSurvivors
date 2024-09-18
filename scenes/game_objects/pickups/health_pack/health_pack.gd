class_name Health_pack extends Pickup

signal collected()

var health_amount = 0

func _ready():
	super._ready()
	$Area2D.area_entered.connect(on_area_entered)
	#self as Pickup
	
	
func on_area_entered(area_entered):
	var collector = area_entered.owner as Player
	collector.heal(health_amount)

	collected.emit(health_amount)
	SoundManager.play_sound(App.pickup_sound)
	
	queue_free()
