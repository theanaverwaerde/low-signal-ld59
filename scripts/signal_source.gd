class_name SignalSource
extends MeshInstance3D

@onready var full_zone: Area3D = $FullZone
@onready var half_zone: Area3D = $HalfZone
@onready var low_zone: Area3D = $LowZone

func get_signal(player: Node) -> int:
	if full_zone.overlaps_body(player):
		return 3
	
	if half_zone.overlaps_body(player):
		return 2
	
	if low_zone.overlaps_body(player):
		return 1
	
	return 0
