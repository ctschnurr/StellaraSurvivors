extends GPUParticles2D

@export var small_asteroid: PackedScene
@export var med_asteroid: PackedScene


func _ready():
	pass
	
	
func burst(burst_asteroid: Asteroid):
	var holder: Node2D
	add_child(holder)
	holder.position = position
	
	match burst_asteroid.size:
		Asteroid.Asteroid_size.MEDIUM:
			var amount = randf_range(2, 4)
			for n in amount:
				small_asteroid.instantiate
			pass
			
		Asteroid.Asteroid_size.LARGE:
			pass
		
	
	

