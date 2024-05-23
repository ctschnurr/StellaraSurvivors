extends CanvasLayer

@onready var sfx_volume_slider: Slider = %Sound_effects_volume
@onready var music_volume_slider: Slider = %Music_volume
@onready var back_button = %BackButton
var back_scene_name: String


func _ready():
	back_button.grab_focus()
	back_button.pressed.connect(go_back)
	back_button.focus_entered.connect(on_focus_entered)
	back_button.mouse_entered.connect(on_back_entered)
	sfx_volume_slider.value_changed.connect(adjust_sound_volume)
	sfx_volume_slider.value = SoundManager.get_sound_volume()
	sfx_volume_slider.mouse_entered.connect(on_sfx_entered)
	sfx_volume_slider.focus_entered.connect(on_focus_entered)
	music_volume_slider.value_changed.connect(adjust_music_volume)
	music_volume_slider.value = SoundManager.get_music_volume()
	music_volume_slider.mouse_entered.connect(on_music_entered)
	music_volume_slider.focus_entered.connect(on_focus_entered)


func adjust_sound_volume(value):
	SoundManager.set_sound_volume(value)
	
	
func adjust_music_volume(value):
	SoundManager.set_music_volume(value)
	
	
func on_focus_entered():
	SoundManager.play_sound(App.asteroid_collision_sound)


func on_back_entered():
	back_button.grab_focus()
	
	
func on_sfx_entered():
	sfx_volume_slider.grab_focus()
	
	
func on_music_entered():
	music_volume_slider.grab_focus()
	

func go_back():
	App.screen_manager.back_button(back_scene_name)
	queue_free()
