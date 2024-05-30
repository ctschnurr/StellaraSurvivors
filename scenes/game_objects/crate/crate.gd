class_name Crate extends Destructable_object

@export var screen_shake_amount:float = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	object_sprite = %Crate_sprite
	size_multiplier = 3
	
	await get_tree().create_timer(30).timeout
	if !has_entered_play_area: 
		queue_free()
