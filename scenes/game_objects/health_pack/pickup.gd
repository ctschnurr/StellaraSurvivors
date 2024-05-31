class_name Pickup extends CharacterBody2D

@export var raycast_shape = load("res://scenes/game_objects/health_pack/pickup_ray_sphere.tres")
var player_in_range: bool = false
@onready var shapecast: ShapeCast2D = %ShapeCast


func _ready():
	pass
	
	
func _process(delta):
	if App.player != null:
	
		if App.player != null and global_position.distance_to(App.player.global_position) < App.pickup_attract_distance:
			var target_velocity = global_position.direction_to(App.player.global_position) * (App.pickup_attract_distance / global_position.distance_to(App.player.global_position) * 25)
		
			velocity = velocity.lerp(target_velocity, 1 - exp(-delta * 5))
			move_and_slide()
		
		
func _physics_process(delta):
	if App.player == null: return
	
	shapecast.force_shapecast_update()
	fire_raycast(delta)
	
		
func fire_raycast(_delta):	
	if shapecast.is_colliding():
		var number = shapecast.get_collision_count()
		for n in number:
			var collided = shapecast.get_collider(n)
			if collided is Pickup:
				var direction = global_position.direction_to(collided.global_position)
				if direction == Vector2.ZERO: direction = Vector2(randf_range(-1, 1), randf_range(-1, 1))
				
				collided.global_position += direction

