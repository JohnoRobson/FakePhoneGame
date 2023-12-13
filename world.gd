class_name World
extends Node

var player: Player
@onready var spawner: Spawner = $Spawner
@onready var start_panel: StartPanel = $StartPanel
@onready var dead_label: Label = $DeadLabel
@onready var win_label: Label = $WinLabel

const POINTS_TO_WIN: int = 2	

func _ready() -> void:
	dead_label.modulate = Color.TRANSPARENT

func start_game() -> void:
	start_panel.disappear()
	spawner.restart()
	player = preload("res://player.tscn").instantiate()
	add_child(player)
	spawner.player = player
	player.player_dead.connect(game_over.bind())
	player.dudes_updated.connect(check_for_win.bind())

func game_over() -> void:
	dead_label.modulate = Color.TRANSPARENT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(dead_label, "modulate", Color.WHITE, 1)
	await get_tree().create_timer(1).timeout
	var tween_out: Tween = get_tree().create_tween()
	tween_out.tween_property(dead_label, "modulate", Color.TRANSPARENT, 1)

	start_panel.appear()

func check_for_win(new_dude_count: int) -> void:
	if new_dude_count >= POINTS_TO_WIN:
		win()

func win() -> void:
	player.player_dead.disconnect(game_over.bind())
	player.dudes_updated.disconnect(check_for_win.bind())

	win_label.modulate = Color.TRANSPARENT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(win_label, "modulate", Color.WHITE, 1)
	
	await get_tree().create_timer(1).timeout

	var tween_out: Tween = get_tree().create_tween()
	tween_out.tween_property(win_label, "modulate", Color.TRANSPARENT, 1)
	
	player.dead()

	start_panel.appear()