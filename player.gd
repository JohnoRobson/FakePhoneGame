class_name Player
extends Node3D

@onready var area: Area3D = $Area3D
@onready var label: Label3D = $Label3D

signal player_dead()
signal dudes_updated(count: int)

var dudes: Array[Dude] = []

var count: int:
	set(new_value):
		var old_count: int = count
		if new_value < 0:
			count = 0 # count cannot go below 0
			update_dudes(old_count, new_value)
		else:
			count = new_value
			update_dudes(old_count, new_value)
	get:
		return count

const SPEED: float = 5.0
const DUDE_WIDTH: float = 1.0
const RELOAD_TIME: float = 1.0

var timer: float = 0.0
var bullet_scene: PackedScene = preload("res://bullet.tscn")

func _process(delta: float) -> void:
	timer += delta
	if timer >= RELOAD_TIME:
		shoot()
		timer = 0

func _ready() -> void:
	count = 1

func shoot() -> void:
	for dude: Dude in dudes:
		var bullet: Bullet = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = dude.global_position + Vector3(0, 1, 0)

func get_position_for_index(index: int) -> Vector3:
	# get z
	var i: int = 1
	while (triangle_number_sequence(i) < index):
		i += 1
	
	# subtract 1 because I want a zero-indexed z index
	var z: float = (i - 1) * DUDE_WIDTH

	# get x
	var triangle_level_width: float = i * DUDE_WIDTH

	var x: float = -(triangle_level_width / 2) + (triangle_level_width / i) * (triangle_number_sequence(i) - index) * DUDE_WIDTH + DUDE_WIDTH / 2
	
	return Vector3(x, 0.0, z)

func triangle_number_sequence(n: int) -> int:
	@warning_ignore("integer_division")
	return (n * (n + 1)) / 2

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, 0.0)).normalized()
	if direction:
		position.x += direction.x * SPEED * delta

func update_dudes(old_count: int, new_count: int) -> void:
	label.text = str(count)
	dudes_updated.emit(new_count)
	if new_count <= 0:
		dead()

	if old_count > new_count:
		if dudes.is_empty():
			dead()
			return
		for n: int in range(old_count, new_count, -1):
			if n >	 0:
				var dude: Dude = dudes.pop_back()
				dude.dead()
			else:
				dead()
				break
	else:
		for n: int in range(old_count, new_count):
			var dude: Dude = preload("res://dude.tscn").instantiate()
			add_child(dude)
			dude.position = get_position_for_index(n + 1)
			dudes.append(dude)

func dead() -> void:
	label.hide()
	player_dead.emit()
	area.hide()
	area.monitorable = false
	area.monitoring = false

	for dude: Dude in dudes:
		dude.dead()
	dudes.clear()
	await get_tree().create_timer(2.5).timeout
	queue_free()
