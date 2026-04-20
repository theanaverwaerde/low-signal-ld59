extends Light3D

@export var speed : float = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	visible = fmod(Time.get_ticks_msec() / 1000* speed, 1) > .5
