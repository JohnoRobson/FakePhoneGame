class_name Bullet
extends Area3D

var speed: float = 20.0
var lifetime: float = 1.0
var time_alive: float = 0	

func _physics_process(delta: float) -> void:
	position += Vector3.FORWARD * delta * speed
	time_alive += delta

	if time_alive >= lifetime:
		queue_free()

	for area: Area3D in get_overlapping_areas():
		if area is Enemy: # they all should be
			var enemy: Enemy = area as Enemy
			enemy.health -= 1
			queue_free()
			return