extends Node

signal money_changed(new_amount: int)
signal inventory_changed(item_id: String, new_amount: int)

var money: int = 100
var inventory: Dictionary = {}

func _ready() -> void:
	print("InventoryManager inicializado. Dinero inicial: ", money)
	# Semillas iniciales
	add_item("seed_basic", 5)

func add_money(amount: int) -> void:
	money += amount
	money_changed.emit(money)

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		return true
	return false

func add_item(item_id: String, amount: int = 1) -> void:
	if inventory.has(item_id):
		inventory[item_id] += amount
	else:
		inventory[item_id] = amount
	inventory_changed.emit(item_id, inventory[item_id])

func remove_item(item_id: String, amount: int = 1) -> bool:
	if inventory.has(item_id) and inventory[item_id] >= amount:
		inventory[item_id] -= amount
		var remaining = inventory[item_id]
		if remaining <= 0:
			inventory.erase(item_id)
		inventory_changed.emit(item_id, remaining)
		return true
	return false

func get_item_amount(item_id: String) -> int:
	return inventory.get(item_id, 0)
