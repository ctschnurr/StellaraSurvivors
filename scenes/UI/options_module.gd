class_name OptionsModule extends MarginContainer

@onready var sfx_volume_slider: Slider = %Sound_effects_volume
@onready var music_volume_slider: Slider = %Music_volume
var back_scene_name: String


func _ready():
	sfx_volume_slider.value_changed.connect(adjust_sound_volume)
	sfx_volume_slider.value = SoundManager.get_ambient_sound_volume()
	sfx_volume_slider.mouse_entered.connect(on_sfx_entered)
	sfx_volume_slider.focus_entered.connect(on_focus_entered)
	music_volume_slider.value_changed.connect(adjust_music_volume)
	music_volume_slider.value = SoundManager.get_music_volume()
	music_volume_slider.mouse_entered.connect(on_music_entered)
	music_volume_slider.focus_entered.connect(on_focus_entered)


func adjust_sound_volume(value):
	SoundManager.set_ambient_sound_volume(value)
	SoundManager.set_sound_volume(value)
	print("Sound: ", value)
	
	
func adjust_music_volume(value):
	SoundManager.set_music_volume(value)
	print("Music: ", value)
	
	
func on_focus_entered():
	SoundManager.play_ambient_sound(App.asteroid_collision_sound)
	
	
func on_sfx_entered():
	sfx_volume_slider.grab_focus()
	
	
func on_music_entered():
	music_volume_slider.grab_focus()

