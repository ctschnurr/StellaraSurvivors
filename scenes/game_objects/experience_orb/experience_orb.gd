class_name Experience_orb extends CharacterBody2D
var xp_amount: float = 1
@onready var sprite = $Sprite2D
@onready var pickup_sound: AudioStream = load("res://resources/audio/pickup_xp.wav")
var player: Player
var tween = Tween 

signal collected(xp: float)

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	player = App.player
	
	if xp_amount <= 1: sprite.modulate = Color(0, 0, 1)
	elif xp_amount > 1 and xp_amount <= 2: sprite.modulate = Color(0, 1, 0)
	elif xp_amount > 2: sprite.modulate = Color(1, 0, 0)
	
	var base_color = sprite.modulate
	
	tween = get_tree().create_tween()
	tween.set_loops(99).tween_property(sprite, "modulate", Color(1, 1, 1), 0.5)
	tween.tween_property(sprite, "modulate", base_color, 0.5)
	
	
func on_area_entered(_area_entered):
	SoundManager.play_sound_with_pitch(pickup_sound, 0.25)
	collected.emit(xp_amount)
	tween.stop()
	queue_free()
	
	
func _process(delta):
	if player == null: return
	var distance_to_player: float = global_position.distance_to(player.global_position)
	var direction_to_player: Vector2 = global_position.direction_to(player.global_position)
	
	if distance_to_player < App.orb_attract_distance:
		var target_velocity = direction_to_player * (App.orb_attract_distance / distance_to_player * 25)
			
		velocity = velocity.lerp(target_velocity, 1 - exp(-delta * 5))
		move_and_slide()
		
