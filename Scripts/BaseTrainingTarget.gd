extends Area3D
class_name BaseTrainingTarget

signal target_destroyed

@export var points: int = 100
@export var target_size: float = 1.0
@export var respawn_time: float = 3.0

var is_active: bool = true

func _ready():
	add_to_group("targets")

func hit():
	if not is_active: return
	destroy_target()

func destroy_target():
	is_active = false
	target_destroyed.emit()
	
	# Ocultar y deshabilitar
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", true)
			
	if respawn_time > 0.0:
		var timer = get_tree().create_timer(respawn_time)
		timer.timeout.connect(respawn_target)
	else:
		queue_free()

func respawn_target():
	is_active = true
	show()
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)
