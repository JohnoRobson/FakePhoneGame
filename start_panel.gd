class_name StartPanel
extends Panel

@onready var button: Button = $Button

func _ready() -> void:
	appear()

func appear() -> void:
	button.disabled = false
	modulate = Color.TRANSPARENT
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1)

func disappear() -> void:
	button.disabled = true
	modulate = Color.WHITE
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1)
