class_name BallisticsSystem
extends Node3D

var active: bool = false
var velocity: Vector3 = Vector3.ZERO
var gravity: float = 9.81
var current_lifetime: float = 0.0
var max_lifetime: float = 5.0
var exceptions: Array[RID] = []
var mesh_inst: MeshInstance3D

func _setup_visuals():
	mesh_inst = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.05, 0.05, 0.4)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.8, 0, 1)
	mat.emission_enabled = true
	mat.emission = Color(1, 0.8, 0, 1)
	mat.emission_energy_multiplier = 4.0
	box.material = mat
	mesh_inst.mesh = box
	add_child(mesh_inst)

func ignore_collider(node: CollisionObject3D):
	if node:
		exceptions.append(node.get_rid())

func initialize(start_pos: Vector3, aim_dir: Vector3, muzzle_vel: float, player_vel: Vector3, proj_data: ProjectileData):
	global_position = start_pos
	
	# Limpiar excepciones de usos anteriores en la pool
	exceptions.clear()
	
	# Orientar el trazador visual en la dirección del disparo
	if aim_dir.length_squared() > 0.01 and abs(aim_dir.normalized().y) < 0.99:
		look_at(global_position + aim_dir, Vector3.UP)
	
	# Herencia de velocidad obligatoria: final_velocity = muzzle_velocity + player_velocity
	velocity = (aim_dir.normalized() * muzzle_vel) + player_vel
	
	if proj_data:
		max_lifetime = proj_data.lifetime
		
	current_lifetime = 0.0
	active = true
	visible = true
	set_physics_process(true)

func deactivate():
	active = false
	visible = false
	set_physics_process(false)
	# Retornar al pool en vez de queue_free()
	ProjectileManager.release(self)

func _physics_process(delta: float):
	if not active:
		return
		
	current_lifetime += delta
	if current_lifetime >= max_lifetime:
		deactivate()
		return
		
	# Aplicar gravedad
	velocity.y -= gravity * delta
	
	# Rotar el proyectil visualmente para que siga la parábola (opcional, ayuda al trazador)
	if velocity.length_squared() > 0.1 and abs(velocity.normalized().y) < 0.99:
		look_at(global_position + velocity, Vector3.UP)
	
	var next_pos = global_position + (velocity * delta)
	
	# Swept Collision Detection (CCD)
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, next_pos)
	query.exclude = exceptions
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if result:
		# Impacto detectado
		if ImpactManager:
			ImpactManager.spawn_impact(result.position, result.normal)
			
		if result.collider.has_method("hit"):
			result.collider.hit()
			
		# Mover visualmente al punto exacto del impacto antes de desactivar
		global_position = result.position
		deactivate()
	else:
		global_position = next_pos
