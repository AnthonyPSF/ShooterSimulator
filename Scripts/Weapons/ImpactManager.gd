extends Node

var pool: Array[GPUParticles3D] = []

func _ready():
	# Pre-generar 15 sistemas de partículas de impacto
	for i in range(15):
		var p = _create_particle_system()
		add_child(p)
		pool.append(p)

func spawn_impact(pos: Vector3, normal: Vector3):
	var particles: GPUParticles3D = null
	for p in pool:
		if not p.emitting:
			particles = p
			break
			
	# Si todos están ocupados, creamos uno nuevo dinámicamente
	if not particles:
		particles = _create_particle_system()
		add_child(particles)
		pool.append(particles)
		
	particles.global_position = pos
	
	# Alinear las partículas para que reboten desde la pared hacia afuera
	# (Las partículas emiten hacia su eje -Z, por lo que look_at(pos + normal) es perfecto)
	if normal.length_squared() > 0.1:
		if abs(normal.y) < 0.99:
			particles.look_at(pos + normal, Vector3.UP)
		else:
			particles.look_at(pos + normal, Vector3.RIGHT)
			
	particles.restart()
	
	var audio = particles.get_node_or_null("ImpactSound")
	if audio and audio.stream != null:
		audio.play()
	
func _create_particle_system() -> GPUParticles3D:
	var p = GPUParticles3D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = 12
	p.lifetime = 0.6
	
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, -1) 
	mat.spread = 35.0
	mat.initial_velocity_min = 5.0
	mat.initial_velocity_max = 12.0
	mat.gravity = Vector3(0, -15.0, 0)
	
	# Usar damping para que pierdan velocidad rápido en el aire
	mat.damping_min = 5.0
	mat.damping_max = 8.0
	
	p.process_material = mat
	
	var pass1 = BoxMesh.new()
	pass1.size = Vector3(0.04, 0.04, 0.1) # Forma alargada de chispa
	
	var spat_mat = StandardMaterial3D.new()
	spat_mat.albedo_color = Color(1.0, 0.7, 0.1) 
	spat_mat.emission_enabled = true
	spat_mat.emission = Color(1.0, 0.6, 0.1)
	spat_mat.emission_energy_multiplier = 4.0
	pass1.surface_set_material(0, spat_mat)
	
	p.draw_pass_1 = pass1
	
	# Soporte para sonido de impacto (Iteración 5: Partículas y Sonido)
	var audio = AudioStreamPlayer3D.new()
	audio.name = "ImpactSound"
	audio.unit_size = 3.0
	audio.max_distance = 50.0
	# Si existe un archivo de sonido, lo cargamos dinámicamente.
	# El usuario puede colocar un archivo en esta ruta:
	if ResourceLoader.exists("res://Assets/Sounds/impact.wav"):
		audio.stream = load("res://Assets/Sounds/impact.wav")
	p.add_child(audio)
	
	return p
