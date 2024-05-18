extends CanvasLayer

@onready var objective_text: Label = %Objective_text

func update_objective_text(text: String):
	objective_text.text = text
