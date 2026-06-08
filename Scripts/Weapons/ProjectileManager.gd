extends Node

var pool: Array[Node3D] = []

func _ready():
	pass
	
func get_projectile() -> Node3D:
	print("[DEBUG] ProjectileManager: Solicitando proyectil")
	for proj in pool:
		if not proj.active:
			print("[DEBUG] ProjectileManager: Reutilizando proyectil existente")
			return proj
			
	print("[DEBUG] ProjectileManager: Creando nuevo proyectil dinámicamente")
	# En lugar de cargar un .tscn que puede fallar por parseo,
	# instanciamos un Node3D vacío y le asignamos el script físico.
	var new_proj = Node3D.new()
	new_proj.set_script(preload("res://Scripts/Weapons/BallisticsSystem.gd"))
	
	if new_proj.has_method("_setup_visuals"):
		new_proj._setup_visuals()
	else:
		print("[ERROR] ProjectileManager: BallisticsSystem no tiene _setup_visuals()")
		
	# Lo agregamos directo como hijo del ProjectileManager para organización
	add_child(new_proj)
	pool.append(new_proj)
	print("[DEBUG] ProjectileManager: Proyectil creado y añadido al árbol")
	return new_proj
		
	return null

func release(projectile: Node3D):
	# Ya el proyectil gestiona su propio active = false
	# Simplemente lo mantenemos en la lista para reutilizarlo
	pass
