extends Destructable_object
class_name Asteroid

@export var asteroid_textures: Array[Texture]

@onready var texture_sm_gold = load("res://scenes/game_objects/enemies/asteroids/asteroid_sm_gld.png")
@onready var texture_med_gold = load("res://scenes/game_objects/enemies/asteroids/asteroid_med_gld.png")
@onready var texture_lrg_gold = load("res://scenes/game_objects/enemies/asteroids/asteroid_lg_gld.png")
var golden: bool = false

@export var screen_shake_amount:float = 0.5
enum Asteroid_size{SMALL, MEDIUM, LARGE}
@export var size: Asteroid_size = Asteroid_size.SMALL

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var golden_chance = randi_range(1, 100)
	if golden_chance <= App.GOLDEN_ASTEROID_CHANCE: golden = true
	
	object_sprite = %Asteroid_sprite
	object_sprite.texture = asteroid_textures.pick_random()
	
	match size:
		Asteroid_size.SMALL:
			if golden: object_sprite.texture = texture_sm_gold
		Asteroid_size.MEDIUM:
			size_multiplier = 2
			if golden: object_sprite.texture = texture_med_gold
		Asteroid_size.LARGE:
			size_multiplier = 3
			if golden: object_sprite.texture = texture_lrg_gold
	
	if golden:
		var new_loot = loot_module_array.duplicate()
		
		for loot in new_loot:
			loot.loot_drop_probability = 100
			
		new_loot.append_array(new_loot.duplicate())
		new_loot.append_array(new_loot.duplicate())
		
		loot_module_array = new_loot
		
		health_component.max_health *= 3
		health_component.current_health *= 3
			
	
	await get_tree().create_timer(15).timeout
	if !has_entered_play_area: 
		queue_free()
