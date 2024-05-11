extends CanvasLayer

@onready var player_health_text: Label = %Player_health_text

func update_player_health_text(health: int):
	player_health_text.text = "Player Health: %s" %[health]
