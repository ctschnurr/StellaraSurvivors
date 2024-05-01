extends Area2D
class_name HitboxComponent

var damage = 5

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(_other_area: Area2D):
	owner.queue_free()
