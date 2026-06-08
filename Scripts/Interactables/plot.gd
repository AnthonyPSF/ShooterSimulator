class_name Plot
extends StaticBody3D

@export var is_planted: bool = false
@export var is_ready: bool = false

## Llamada por el RayCast del jugador al interactuar.
func interact() -> void:
	print("Tierra interactuada")
