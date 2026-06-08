extends RayCast3D
class_name InteractionSystem

var current_interactable = null

func _physics_process(delta):
	if is_colliding():
		var collider = get_collider()
		if collider.has_method("on_interact"):
			if current_interactable != collider:
				current_interactable = collider
				# Could emit a signal here to show UI
		else:
			current_interactable = null
	else:
		current_interactable = null

func _unhandled_input(event):
	if event.is_action_pressed("interact") and current_interactable != null:
		var player = owner
		current_interactable.on_interact(player)
