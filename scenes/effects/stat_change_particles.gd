class_name Stat_particles extends CPUParticles2D


@onready var label: Label = %Label

func set_label(string: String, color: Color):
	label.text = string
	label.modulate = color
