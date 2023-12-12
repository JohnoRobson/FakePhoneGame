class_name Enemy
extends Area3D

@onready var label: Label3D = $Label3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var width: float = 5.0
var player: Player
var text: String
var operator: Operator
var speed: float = 14.0
var despawner: Area3D
var health: int:
	set(new_value):
		health = new_value
		if label != null:
			label.text = str(health)
	get:
		return health

func _ready() -> void:
	collision_shape.shape.size.x = width
	collision_shape.shape.size.y = width
	collision_shape.shape.size.z = width
	collision_shape.position.y = width / 2.0
	label.text = str(health)

func _process(_delta: float) -> void:
	if health <= 0:
		queue_free()

func _physics_process(_delta: float) -> void:
	position.z += speed * _delta
	if (player != null and overlaps_area(player.area)):
		player.count -= health
		collision_shape.disabled = true
	if overlaps_area(despawner):
		queue_free()
