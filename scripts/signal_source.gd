class_name SignalSource
extends MeshInstance3D

@onready var player: CharacterBody3D = %Player

@export var zones : Array[Area3D]

signal power_changed

func _ready() -> void:
	for zone in zones:
		zone.body_entered.connect(get_signal_body)
		zone.body_exited.connect(get_signal_body)

func get_signal_body(body):
	if body == player:
		get_signal()

func get_signal() -> int:
	for i in zones.size():
		if zones[i].overlaps_body(player):
			var power = zones.size()-i
			power_changed.emit(power)
			return power
	
	power_changed.emit(0)
	return 0
