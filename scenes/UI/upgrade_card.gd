class_name Upgrade_card extends MarginContainer

signal selected

@onready var name_label: Label = %Name_label
@onready var level_label: Label = %Level_label
@onready var description_label: Label = %Description_label

func _ready():
	gui_input.connect(on_input)
	

func setup_card(upgrade: Player_upgrade, level: int):
	name_label.text = upgrade.name
	level_label.text = str(level)
	description_label.text = upgrade.description
	
	
func on_input(event: InputEvent):
	if event.is_action_pressed("input_fire"):
		selected.emit()

