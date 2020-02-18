extends Node2D

export (String) var initial_zone

func _ready():
	propagate_call("set_bus", [initial_zone])

func set_reverb_zone(current_zone):
	propagate_call("set_bus", [current_zone])
	print(current_zone)

