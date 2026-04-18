extends Camera3D

@onready var camera_3d: Camera3D = %Camera3D

func _process(_delta: float) -> void:
	global_transform = camera_3d.global_transform
	pass
