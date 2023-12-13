class_name DudeModel
extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: Skeleton3D = $metarig/Skeleton3D

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_dead: bool = false
var direction: Vector3

func _ready() -> void:
	animation_player.play("run")

func _physics_process(delta: float) -> void:
	if is_dead:
		for bone in skeleton.get_children():
			if bone is PhysicalBone3D:
				bone.apply_impulse(direction * delta * 20.0)

func ragdoll() -> void:
	skeleton.physical_bones_start_simulation()
	is_dead = true
	if rng.randi_range(0, 1) == 0:
		direction = Vector3.LEFT
	else:
		direction = Vector3.RIGHT