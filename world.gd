class_name World
extends Node

var player: Player
@onready var spawner: Spawner = $Spawner
@onready var start_panel: Panel = $StartPanel

func start_game() -> void:
	start_panel.hide()
	spawner.restart()
	player = preload("res://player.tscn").instantiate()
	add_child(player)
	spawner.player = player
	player.player_dead.connect(game_over.bind())

func game_over() -> void:
	start_panel.show()
