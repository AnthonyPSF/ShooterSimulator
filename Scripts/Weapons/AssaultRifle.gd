extends Node3D
class_name Weapon

signal ammo_changed(current: int, reserve: int)
signal weapon_reloaded()

var weapon_data: WeaponData
var proj_data: ProjectileData
var last_fire_time: float = 0.0

var recoil_system: RecoilSystem
var current_shot_index: int = 0
var time_since_last_shot: float = 0.0

var mesh_inst: MeshInstance3D
var original_mesh_pos: Vector3 = Vector3(0.3, -0.3, -0.6)
var mesh_recoil_offset: Vector3 = Vector3.ZERO

var current_ammo: int = 0
var current_reserve: int = 0
var is_reloading: bool = false

func _ready():
	print("[DEBUG] AssaultRifle inicializado")
	weapon_data = WeaponData.new()
	if name == "Pistol":
		weapon_data.weapon_name = "Pistol 9mm"
		weapon_data.muzzle_velocity = 400.0
		weapon_data.fire_rate = 0.2
		weapon_data.magazine_size = 15
		weapon_data.max_reserve = 60
		weapon_data.reload_time = 1.5
		weapon_data.recoil_pattern = [Vector2(0, 0.8), Vector2(0.2, 0.6), Vector2(-0.2, 0.5)]
	else:
		weapon_data.weapon_name = "Assault Rifle"
		weapon_data.muzzle_velocity = 800.0
		weapon_data.fire_rate = 0.1
		weapon_data.magazine_size = 30
		weapon_data.max_reserve = 90
		weapon_data.reload_time = 2.5
		weapon_data.recoil_pattern = [
			Vector2(0.0, 1.5),
			Vector2(0.2, 1.2),
			Vector2(0.5, 1.0),
			Vector2(-0.1, 0.8),
			Vector2(-0.4, 0.6),
			Vector2(-0.6, 0.5),
			Vector2(0.0, 0.5)
		]
	
	proj_data = ProjectileData.new()
	proj_data.lifetime = 5.0
	
	recoil_system = RecoilSystem.new()
	add_child(recoil_system)
	
	mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.1, 0.2, 0.8)
	mesh_inst.mesh = box
	mesh_inst.position = original_mesh_pos
	add_child(mesh_inst)
	
	current_ammo = weapon_data.magazine_size
	current_reserve = weapon_data.max_reserve
	call_deferred("update_ammo_ui")

func update_ammo_ui():
	ammo_changed.emit(current_ammo, current_reserve)

func reload():
	if is_reloading or current_ammo == weapon_data.magazine_size or current_reserve <= 0:
		return
		
	is_reloading = true
	print("[DEBUG] ", name, " recargando...")
	
	# Mini animación visual de recarga
	var tween = create_tween()
	tween.tween_property(mesh_inst, "rotation_degrees:x", 45.0, 0.3)
	tween.tween_property(mesh_inst, "rotation_degrees:x", 0.0, weapon_data.reload_time - 0.3)
	
	await get_tree().create_timer(weapon_data.reload_time).timeout
	
	var needed = weapon_data.magazine_size - current_ammo
	if current_reserve >= needed:
		current_ammo += needed
		current_reserve -= needed
	else:
		current_ammo += current_reserve
		current_reserve = 0
		
	is_reloading = false
	update_ammo_ui()
	weapon_reloaded.emit()

func _process(delta: float):
	time_since_last_shot += delta
	# Si dejamos de disparar un tiempo, el patrón se reinicia
	if time_since_last_shot > weapon_data.fire_rate * 3.0:
		current_shot_index = 0
		
	# Recuperación del retroceso visual (el arma vuelve a su sitio)
	mesh_recoil_offset = mesh_recoil_offset.lerp(Vector3.ZERO, delta * 15.0)
	if is_instance_valid(mesh_inst):
		mesh_inst.position = original_mesh_pos + mesh_recoil_offset

func fire():
	if is_reloading or current_ammo <= 0:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_fire_time < weapon_data.fire_rate:
		return
		
	current_ammo -= 1
	update_ammo_ui()
		
	last_fire_time = current_time
	time_since_last_shot = 0.0
	
	# Aplicar retroceso visual (el modelo patea hacia atrás y arriba)
	mesh_recoil_offset.z += 0.1
	mesh_recoil_offset.y += 0.02
	
	# Aplicar retroceso mecánico (Cámara)
	if recoil_system and weapon_data.recoil_pattern.size() > 0:
		var idx = min(current_shot_index, weapon_data.recoil_pattern.size() - 1)
		var kick = weapon_data.recoil_pattern[idx]
		recoil_system.add_recoil(deg_to_rad(kick.y), deg_to_rad(kick.x))
		current_shot_index += 1
	
	var proj = ProjectileManager.get_projectile()
	if proj:
		var player_vel = Vector3.ZERO
		var current_node = get_parent()
		var player_node = null
		
		while current_node:
			if current_node is CharacterBody3D:
				player_node = current_node
				player_vel = current_node.velocity
				break
			current_node = current_node.get_parent()
			
		var aim_dir = -global_transform.basis.z
		var muzzle_pos = to_global(Vector3(0.3, -0.3, -1.0))
		
		proj.initialize(muzzle_pos, aim_dir, weapon_data.muzzle_velocity, player_vel, proj_data)
		if player_node and proj.has_method("ignore_collider"):
			proj.ignore_collider(player_node)

