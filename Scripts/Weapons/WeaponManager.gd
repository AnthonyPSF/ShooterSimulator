class_name WeaponManager
extends Node3D

signal weapon_switched(weapon_name: String)

var weapons: Array[Weapon] = []
var current_weapon_index: int = -1
var current_weapon: Weapon

func _ready():
	print("[DEBUG] WeaponManager recolectando armas...")
	for child in get_children():
		if child is Weapon:
			weapons.append(child)
			child.hide()
			child.set_process(false)
			
	if weapons.size() > 0:
		equip_weapon(0)

func _process(_delta):
	if current_weapon:
		if Input.is_action_pressed("fire"):
			if current_weapon.has_method("fire"):
				current_weapon.fire()
		if Input.is_action_just_pressed("reload"):
			if current_weapon.has_method("reload"):
				current_weapon.reload()
				
	if Input.is_action_just_pressed("weapon_1"):
		equip_weapon(0)
	if Input.is_action_just_pressed("weapon_2"):
		equip_weapon(1)

func equip_weapon(index: int):
	if index < 0 or index >= weapons.size() or current_weapon_index == index:
		return
		
	if current_weapon:
		current_weapon.hide()
		current_weapon.set_process(false)
		
	current_weapon_index = index
	current_weapon = weapons[index]
	current_weapon.show()
	current_weapon.set_process(true)
	
	print("[DEBUG] Arma equipada: ", current_weapon.name)
	
	if current_weapon.weapon_data:
		weapon_switched.emit(current_weapon.weapon_data.weapon_name)
	current_weapon.call_deferred("update_ammo_ui")
	print("Arma equipada: ", current_weapon.name)
