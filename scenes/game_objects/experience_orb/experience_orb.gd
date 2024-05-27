class_name Experience_orb extends Pickup
@export var xp_amount: float = 1
@onready var pickup_sound: AudioStream = load("res://resources/audio/pickup_xp.wav")

signal collected(xp: float)

func _ready():
	super._ready()
	$Area2D.area_entered.connect(on_area_entered)
	
	
func on_area_entered(_area_entered):
	SoundManager.play_sound_with_pitch(pickup_sound)
	collected.emit(xp_amount)
	queue_free()
		
