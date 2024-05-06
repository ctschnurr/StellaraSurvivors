extends Area2D
class_name HitboxComponent

@export var hurtbox: HurtboxComponent
@export var damage: int

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D):
	if hurtbox == null:
		owner.queue_free()
