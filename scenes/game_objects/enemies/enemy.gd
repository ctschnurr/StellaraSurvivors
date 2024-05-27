class_name Enemy extends CharacterBody2D

var enemy_sprite: Sprite2D
@onready var health_component = %HealthComponent
@export var loot_dictionary: Array[Loot_module]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
