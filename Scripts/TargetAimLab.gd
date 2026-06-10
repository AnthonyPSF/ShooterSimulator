extends Area3D

signal target_destroyed

var points = 100

func _ready():
	add_to_group("targets")

func hit():
	target_destroyed.emit()
	queue_free()
