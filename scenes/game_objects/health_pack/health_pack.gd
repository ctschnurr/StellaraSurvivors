class_name Health_pack extends Pickup
@onready var pickup_sound: AudioStream = load("res://resources/audio/pickup_xp.wav")

signal collected()

func _ready():
	super._ready()
	$Area2D.area_entered.connect(on_area_entered)
	#self as Pickup


func _process(delta):
	super._process(delta)
	
	
func on_area_entered(_area_entered):
	SoundManager.play_sound_with_pitch(pickup_sound, 0.25)
	print("Health Pack Collected")
	queue_free()
