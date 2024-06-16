class_name Pulse_ability extends CharacterBody2D

@onready var shape_resource = load("res://scenes/game_objects/pulse_ability/pulse_shape.tres")
@onready var pulse = $Area2D/PulseShape
@onready var sprite = %Sprite

var pulse_strength = 5

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
	pulse.shape = shape_resource.duplicate()
	explode(pulse_strength)
	
	
func explode(strength: int):
	sprite.play()
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(5, 5), 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate:a", 0, 0.5).set_ease(Tween.EASE_OUT)
	await sprite.animation_finished
	queue_free()
	
	
func on_area_entered(other_area: Area2D):
	fire_raycast(other_area.global_position)

	
func fire_raycast(other_area_pos: Vector2):
	var space_state = get_world_2d().direct_space_state
	var raycast = PhysicsRayQueryParameters2D.create(global_position, other_area_pos)
	raycast.exclude = [self]
	
	var raycast_output = space_state.intersect_ray(raycast)
	
	if !raycast_output.is_empty():
					
		if raycast_output.collider is Destructable_object:
			var direction = global_position.direction_to(raycast_output.collider.global_position)
			raycast_output.collider.respond_to_pulse_collision(direction, raycast_output.position, pulse_strength)
