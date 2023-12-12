class_name PlayerGate
extends Area3D

@onready var label: Label3D = $Label3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var width: float = 5.0
var player: Player
var text: String
var operator: Operator
var speed: float = 14.0
var despawner: Area3D

func _ready() -> void:
	collision_shape.shape.size.x = width
	label.text = operator.text

func _physics_process(_delta: float) -> void:
	position.z += speed * _delta
	if (player != null and overlaps_area(player.area)):
		operator.expression.call()
		queue_free()
	if overlaps_area(despawner):
		queue_free()
	
