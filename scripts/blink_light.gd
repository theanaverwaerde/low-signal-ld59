extends Light3D

@export var speed : float = 1

const LIGHTBLINK = preload("uid://c25x6ipnmlb0q")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var active = fmod(Time.get_ticks_msec() * speed / 1000, 1) > .5
	LIGHTBLINK.set_shader_parameter("Enable", active)

	visible = active
