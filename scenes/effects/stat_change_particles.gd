class_name Stat_particles extends CPUParticles2D


@onready var label: Label = %ParticleLabel

func set_label(input_number: int, color_input: Color):
	input_number *= App.STAT_CHANGE_PARTICLE_MULTIPLIER
	label.text = str(input_number)
	label.modulate = color_input
