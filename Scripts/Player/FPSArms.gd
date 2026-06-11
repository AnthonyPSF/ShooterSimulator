extends Node3D

@export var right_shoulder_pos: Vector3 = Vector3(0.15, -0.25, -0.1)
@export var left_shoulder_pos: Vector3 = Vector3(-0.2, -0.2, 0.0)

var current_weapon_node: Node3D = null

@onready var right_hand = $RightHand
@onready var left_hand = $LeftHand
@onready var right_arm = $RightArm
@onready var left_arm = $LeftArm

var default_right_grip: Vector3 = Vector3(0.1, -0.1, -0.3)
var default_left_grip: Vector3 = Vector3(-0.1, -0.1, -0.5)

var debug_timer = 0.0
var debug_state = 0

func _ready():
	# Configurar mallas base si no tienen
	var hand_mesh = BoxMesh.new()
	hand_mesh.size = Vector3(0.08, 0.08, 0.1)
	
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.2, 0.2) # Guantes oscuros
	hand_mesh.material = mat
	
	right_hand.mesh = hand_mesh
	left_hand.mesh = hand_mesh
	
	var arm_mesh = BoxMesh.new()
	arm_mesh.size = Vector3(0.04, 1.0, 0.04) # Grosor base, altura 1.0
	
	var arm_mat = StandardMaterial3D.new()
	arm_mat.albedo_color = Color(0.3, 0.4, 0.3) # Mangas verdes
	arm_mesh.material = arm_mat
	
	right_arm.mesh = arm_mesh
	left_arm.mesh = arm_mesh
	
	# Rotamos el cilindro para que el eje Y apunte hacia Z negativo
	# El CylinderMesh crece en Y, necesitamos que apunte al objetivo
	
	var wm = get_node_or_null("../WeaponManager")
	if wm:
		wm.weapon_switched.connect(_on_weapon_switched)
		if wm.current_weapon:
			_bind_to_weapon(wm.current_weapon)

func _on_weapon_switched(weapon_name: String):
	var wm = get_node_or_null("../WeaponManager")
	if wm and wm.current_weapon:
		_bind_to_weapon(wm.current_weapon)

func _bind_to_weapon(weapon_node: Node3D):
	current_weapon_node = weapon_node

func _process(delta):
	var r_target = to_global(default_right_grip)
	var l_target = to_global(default_left_grip)
	var r_rot = global_transform.basis
	var l_rot = global_transform.basis
	
	debug_timer += delta
	if debug_timer > 1.0 and debug_state == 0:
		var ev = InputEventKey.new()
		ev.keycode = KEY_2
		ev.pressed = true
		Input.parse_input_event(ev)
		debug_state = 1
		print("DEBUG: Pressed 2")
	
	if debug_timer > 2.0 and debug_state == 1:
		get_viewport().get_texture().get_image().save_png("res://debug_shot_pistol.png")
		debug_state = 2
		print("DEBUG SHOT PISTOL SAVED")
	
	if current_weapon_node and is_instance_valid(current_weapon_node):
		# El current_weapon_node es AssaultRifle o Pistol
		# Buscamos los Marker3D inyectados, o calculamos posiciones relativas
		var r_grip = current_weapon_node.get_node_or_null("RightGrip")
		var l_grip = current_weapon_node.get_node_or_null("LeftGrip")
		
		# Si el arma se está moviendo por el retroceso (tiene un mesh_inst con la animación)
		# intentaremos usar el transform de ese mesh si existe.
		var active_model = null
		if current_weapon_node.has_method("get_mesh_inst"):
			active_model = current_weapon_node.mesh_inst
		else:
			for child in current_weapon_node.get_children():
				if child is Node3D and child.name.ends_with("Model"):
					active_model = child
					break
		
		if active_model:
			# Agregamos los grips al weapon_node (coordenadas limpias: X=Derecha, -Z=Frente)
			if not r_grip:
				r_grip = Marker3D.new()
				r_grip.name = "RightGrip"
				current_weapon_node.add_child(r_grip)
				if current_weapon_node.name == "Pistol":
					r_grip.position = Vector3(0.20, -0.16, -0.38) # Justo en el mango (más arriba y centrado)
				else:
					r_grip.position = Vector3(0.22, -0.16, -0.25) # Cerca de la culata/gatillo del rifle
			if not l_grip:
				l_grip = Marker3D.new()
				l_grip.name = "LeftGrip"
				current_weapon_node.add_child(l_grip)
				if current_weapon_node.name == "Pistol":
					l_grip.position = Vector3(0.18, -0.17, -0.40) # Envolviendo la mano derecha y apoyando abajo
				else:
					l_grip.position = Vector3(0.23, -0.17, -0.7) # En el cañón del rifle
					
			var recoil_offset = Vector3.ZERO
			if current_weapon_node.get("mesh_recoil_offset") != null:
				recoil_offset = current_weapon_node.mesh_recoil_offset
				
			r_target = r_grip.global_position + recoil_offset
			l_target = l_grip.global_position + recoil_offset
			r_rot = r_grip.global_transform.basis
			l_rot = l_grip.global_transform.basis
			
			# Ajustar grosor del brazo según arma
			if current_weapon_node.name == "Pistol":
				right_arm.mesh.size = Vector3(0.04, 1.0, 0.04)
				left_arm.mesh.size = Vector3(0.04, 1.0, 0.04)
			else:
				right_arm.mesh.size = Vector3(0.06, 1.0, 0.06)
				left_arm.mesh.size = Vector3(0.06, 1.0, 0.06)
			
	# Colocar las manos
	right_hand.global_position = r_target
	right_hand.global_transform.basis = r_rot
	left_hand.global_position = l_target
	left_hand.global_transform.basis = l_rot
	
	# Estirar y orientar los brazos
	_update_arm(right_arm, to_global(right_shoulder_pos), r_target)
	_update_arm(left_arm, to_global(left_shoulder_pos), l_target)

func _update_arm(arm_node: MeshInstance3D, shoulder_pos: Vector3, hand_pos: Vector3):
	var dir = hand_pos - shoulder_pos
	var dist = dir.length()
	
	# Colocar en el punto medio
	arm_node.global_position = shoulder_pos + dir * 0.5
	
	if dist > 0.001:
		# Hacer que el brazo apunte hacia la mano. 
		# Como el CylinderMesh crece en Y, Look_at hace que Z apunte a la mano.
		# Necesitamos rotarlo 90 grados en X para que Y apunte a la mano.
		arm_node.look_at(hand_pos, Vector3.UP)
		arm_node.rotate_object_local(Vector3.RIGHT, PI/2.0)
		
	# Escalar para alcanzar la distancia
	# La escala base en Y del cilindro es 1.0, así que escala Y = dist
	arm_node.scale = Vector3(1.0, dist, 1.0)
