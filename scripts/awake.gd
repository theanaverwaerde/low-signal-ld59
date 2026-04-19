extends Control

signal awake

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and not animation_player.is_playing():
		animation_player.play("awakeAnimation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	awake.emit()
	queue_free()
