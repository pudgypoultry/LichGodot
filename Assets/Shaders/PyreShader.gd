extends Node3D

@export var particles : Array[GPUParticles3D]
@export var lifetime : float

func StartMe():
	for particle in particles:
		particle.emitting = true
	await get_tree().create_timer(lifetime).timeout
	for particle in particles:
		particle.emitting = false
	
