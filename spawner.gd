class_name Spawner
extends Node

var player: Player
@export var despawner: Area3D

var timer: float = 0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var first_gate: bool = true

const GATE_DISTANCE: float = 80.0

const GATE_WIDTH: float = 5.0

const TIME_BETWEEN_GATES: float = 4.0

const PRIME_NUMBERS: Array[int] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53]

enum GATE_POSITION {
	LEFT, RIGHT
}

func _ready() -> void:
	restart()

func _process(delta: float) -> void:
	timer += delta
	if timer >= TIME_BETWEEN_GATES:
		timer = 0.0
		make_gates()

func get_player_count() -> int:
	if player != null:
		return player.count
	else:
		return 7

func restart() -> void:
	for gate: Node3D in get_tree().get_nodes_in_group("gates"):
		gate.queue_free()
	first_gate = true
	timer = TIME_BETWEEN_GATES # to make a gate spawn immediately

func make_gates() -> void:
	if first_gate: # make the first gate passable by a player with a count of 1
		make_gate(GATE_POSITION.LEFT, make_operator_that_modifies_by_n(1, 1))
		make_gate(GATE_POSITION.RIGHT, make_operator_that_modifies_by_n(-1, 1))
		first_gate = false
	else:
		var a: int = rng.randi_range(0, 1)
		if a == 0:
			# two gates
			var gate_num: Array[int] = [get_player_count() / 2, -get_player_count() / 2]
			gate_num.shuffle()	
			make_gate(GATE_POSITION.LEFT, make_operator_that_modifies_by_n(gate_num[0], 1))
			make_gate(GATE_POSITION.RIGHT, make_operator_that_modifies_by_n(gate_num[1], 1))
		else:
			var pos: Array[GATE_POSITION] = [GATE_POSITION.LEFT, GATE_POSITION.RIGHT]
			pos.shuffle()
			make_gate(pos[0], make_operator_that_modifies_by_n(-get_player_count() / 2, 1))
			make_enemy(pos[1], get_player_count() * 2 + 1)


func make_gate(gate_position: GATE_POSITION, operator: Operator) -> void:
	var x_position: float = -GATE_WIDTH if gate_position == GATE_POSITION.LEFT else GATE_WIDTH
	var gate: PlayerGate = preload("res://gate.tscn").instantiate()
	gate.player = player
	gate.width = GATE_WIDTH
	gate.operator = operator
	gate.despawner = despawner
	get_parent().add_child(gate)
	gate.position = Vector3(x_position / 2.0, 0.0, -GATE_DISTANCE)

func make_enemy(enemy_position: GATE_POSITION, health: int) -> void:
	var x_position: float = -GATE_WIDTH if enemy_position == GATE_POSITION.LEFT else GATE_WIDTH
	var enemy: Enemy = preload("res://enemy.tscn").instantiate()
	enemy.player = player
	enemy.width = GATE_WIDTH
	enemy.despawner = despawner
	enemy.health = health
	get_parent().add_child(enemy)
	enemy.position = Vector3(x_position / 2.0, 0.0, -GATE_DISTANCE)

func make_operator_that_modifies_by_n(n: int, length: int) -> Operator:
	var operator: Operator = Operator.new();
	
	if player != null:
		operator.expression = func() -> void: player.count += n
	else:
		operator.expression = func() -> void: 1 + 1 # intentional

	operator.text = make_equation_string_for(n, length)

	return operator

func make_equation_string_for(n: int, length: int) -> String:
	var string: String = ""
	for number: int in make_list_that_sums_to(n, length):
		string += make_expression_that_equals(number)
	return string

func make_list_that_sums_to(n: int, length: int) -> Array[int]:
	if length == 1:
		return [n]
	var number: int = n
	var array: Array[int] = []
	for i: int in range(0, length):
		var q: int = rng.randi_range(0, number)
		array.append(q)
		number -= q

	return array

func make_expression_that_equals(n: int) -> String:
	var type: int = rng.randi_range(0, 3)

	match type:
		0: #addition
			# take n, take away x, sum x and n
			var x: int = rng.randi_range(0, n)
			return "%s + %s" % [n - x, x]

		1: # subtraction
			# take n, add x, subtract x from n
			var x: int = rng.randi_range(1, 9)
			return "%s - %s" % [n + x, x]
		2: # multiplication
			if n == 0:
				return "%s x %s" % [0, rng.randi_range(0, 9)]
			elif n <= 2 or is_prime_number(n):
				return "%s x %s" % [1, n]
			else:
				# get prime factors i guess?
				var factors: Array[int] = get_prime_factors(n)
				var string: String = ""
				for f: int in factors:
					string += "%s x " % f
				
				return string.substr(0, string.length() - 3)
		_:
			return str(n)
		# 3: # division

# n must be greater than 1
func get_prime_factors(n: int) -> Array[int]:
	var prime_factors: Array[int] = []
	var number: int = n
	var current_prime_index: int = 0
	while number > 0:
		if current_prime_index > PRIME_NUMBERS.size() - 2:
			prime_factors.append(number)
			break
		var current_prime: int = PRIME_NUMBERS[current_prime_index]
		if is_evenly_divisible_by_x(number, current_prime):
			prime_factors.append(current_prime)
			@warning_ignore("integer_division")
			number = number / current_prime
			current_prime_index = 0
		else:
			current_prime_index += 1
	
	return prime_factors

func is_prime_number(n: int) -> bool:
	return PRIME_NUMBERS.has(n)

func is_evenly_divisible_by_x(n: int, x: int) -> bool:
	return n % x == 0
