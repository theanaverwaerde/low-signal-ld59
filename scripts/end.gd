extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var endsound: AudioStreamPlayer = $endsound

func _end() -> void:
	visible = true
	endsound.play()
	animation_player.play("end_anim")
