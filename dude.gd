class_name Dude
extends Node3D

@onready var dude_model: DudeModel = $DudeModel

func dead() -> void:
	dude_model.ragdoll()
	await get_tree().create_timer(2.0).timeout
	queue_free()