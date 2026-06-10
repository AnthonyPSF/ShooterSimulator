extends Area3D
class_name BaseTrainingTarget

signal target_destroyed

@export var points: int = 100
@export var target_size: float = 1.0

func _ready():
	add_to_group("targets")

func hit():
	destroy_target()

func destroy_target():
	target_destroyed.emit()
	queue_free()
