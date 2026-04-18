class_name SignalSource
extends MeshInstance3D

@onready var full_zone: Area3D = $FullZone
@onready var half_zone: Area3D = $HalfZone
@onready var low_zone: Area3D = $LowZone

@onready var player: CharacterBody3D = %Player

var zones : Array[Area3D]

const MAX_POWER : int = 3

signal power_changed

func _ready() -> void:
	zones = [full_zone, half_zone, low_zone]
	
	for zone in zones:
		zone.body_entered.connect(get_signal_body)
		zone.body_exited.connect(get_signal_body)

func get_signal_body(body):
	if body == player:
		get_signal()

func get_signal() -> int:
	for i in zones.size():
		if zones[i].overlaps_body(player):
			var power = MAX_POWER-i
			power_changed.emit(power)
			return power
	
	power_changed.emit(0)
	return 0
