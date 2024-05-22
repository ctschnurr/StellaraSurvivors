class_name Upgrade_card extends MarginContainer

signal selected

@onready var name_label: Label = %Name_label
@onready var level_label: Label = %Level_label
@onready var description_label: Label = %Description_label
@onready var panel = %PanelContainer

func _ready():
	panel.pressed.connect(on_input)
	

func setup_card(upgrade: Player_upgrade, level: int):
	name_label.text = upgrade.name
	level_label.text = str(level)
	description_label.text = upgrade.description
	
	
func on_input():
	selected.emit()

