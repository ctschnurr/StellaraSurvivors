extends CanvasLayer

@onready var progress_bar = $MarginContainer/ProgressBar

func _ready():
	progress_bar.value = 0
	App.experience_manager.update_experience.connect(update_xp_bar)


func update_xp_bar(current_xp: float, target_xp: float):
	var percent = current_xp / target_xp
	progress_bar.value = percent
