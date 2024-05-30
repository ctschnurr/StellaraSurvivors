extends Destructable_object
class_name Asteroid

@export var asteroid_textures: Array[Texture]

@export var screen_shake_amount:float = 0.5
enum Asteroid_size{SMALL, MEDIUM, LARGE}
@export var size: Asteroid_size = Asteroid_size.SMALL

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	object_sprite = %Asteroid_sprite
	object_sprite.texture = asteroid_textures.pick_random()
	
	match size:
		Asteroid_size.SMALL:
			pass
		Asteroid_size.MEDIUM:
			size_multiplier = 2
		Asteroid_size.LARGE:
			size_multiplier = 3
	
	await get_tree().create_timer(15).timeout
	if !has_entered_play_area: 
		queue_free()
