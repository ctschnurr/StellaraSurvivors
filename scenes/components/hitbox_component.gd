extends Area2D
class_name HitboxComponent

@export var hurtbox: HurtboxComponent
@export var damage: int

signal hit

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(_other_area: Area2D):
	if hurtbox == null:
		hit.emit()
		App.camera.add_trauma(0.1 + (damage * .01))
		owner.queue_free()
