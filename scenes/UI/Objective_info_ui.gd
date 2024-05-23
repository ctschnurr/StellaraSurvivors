extends CanvasLayer

@onready var objective_text: Label = %Objective_text
@onready var player_score: Label = %Score
@onready var high_score: Label = %High_score

func _ready():
	App.score_updated.connect(update_score)


func update_objective_text(text: String):
	objective_text.text = text
	
	
func update_score(new_player_score, new_high_score):
	player_score.text = "Your Score:\n%010d" % new_player_score
	high_score.text = "High Score:\n%010d" % new_high_score
