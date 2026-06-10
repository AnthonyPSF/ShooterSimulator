class_name Shop
extends StaticBody3D

## Llamada por el RayCast del jugador al interactuar.
func on_interact(player) -> void:
	print("Bienvenido a la tienda. Comprando semilla básica por $10...")
	if InventoryManager.spend_money(10):
		InventoryManager.add_item("seed_basic", 1)
		print("¡Semilla comprada! Dinero restante: ", InventoryManager.money)
	else:
		print("No tienes suficiente dinero.")
