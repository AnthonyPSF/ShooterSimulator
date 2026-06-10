class_name PlayerController
extends CharacterBody3D

## Emitida cuando el jugador interactúa con éxito con un objeto en el mundo.
signal InteractionTriggered(target: Node3D)

@export_group("Movement Settings")
@export var walk_speed: float = 5.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002

@export_group("Viewmodel Settings")
@export var sway_amount: float = 0.005
@export var sway_smoothness: float = 5.0
@export var bob_frequency: float = 10.0
@export var bob_amplitude: float = 0.05

# Obtenemos la gravedad global del proyecto
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head_pivot: Node3D = $HeadPivot
@onready var main_camera: Camera3D = $HeadPivot/MainCamera
@onready var interaction_ray: RayCast3D = $HeadPivot/MainCamera/InteractionRay
@onready var viewmodel_pivot: Node3D = $HeadPivot/MainCamera/ViewmodelPivot

var bob_time: float = 0.0
var target_sway: Vector2 = Vector2.ZERO
var was_on_floor: bool = true


# Comentarios sobre Capas de Colisión / Máscaras asumidas:
# - CharacterBody3D (Player): Collision Layer 1 (Mundo/Físicas Básicas). Mask 1.
# - InteractionRay: Debe estar en la máscara correspondiente a los interactuables (ej. Layer 2),
#   para evitar que colisione con la propia geometría base si no es necesario.

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if not InputMap.has_action("move_forward"):
		InputMap.add_action("move_forward")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_W
		InputMap.action_add_event("move_forward", ev)
	if not InputMap.has_action("move_backward"):
		InputMap.add_action("move_backward")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_S
		InputMap.action_add_event("move_backward", ev)
	if not InputMap.has_action("move_left"):
		InputMap.add_action("move_left")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_A
		InputMap.action_add_event("move_left", ev)
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_D
		InputMap.action_add_event("move_right", ev)
		
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var ev = InputEventKey.new()
		ev.physical_keycode = KEY_E
		InputMap.action_add_event("interact", ev)
		
		# También añadir click izquierdo
		var mouse_ev = InputEventMouseButton.new()
		mouse_ev.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("interact", mouse_ev)
		

	# Instanciar el HUD nativamente por código para evitar romper escenas
	var hud = preload("res://Scripts/Player/PlayerHUD.gd").new()
	add_child(hud)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
		# Calculamos el objetivo del sway basado en el ratón
		target_sway.x = -event.relative.x * sway_amount
		target_sway.y = event.relative.y * sway_amount
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func apply_recoil(pitch_rad: float, yaw_rad: float) -> void:
	rotate_y(-yaw_rad)
	head_pivot.rotate_x(pitch_rad)
	head_pivot.rotation.x = clamp(head_pivot.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if is_on_floor() and not was_on_floor:
		target_sway.y -= 0.15 # Empuje agresivo hacia abajo al aterrizar
	was_on_floor = is_on_floor()
	
	_handle_movement(delta)
	_apply_viewmodel_sway(delta)
	_apply_head_bobbing(delta)

## Maneja la lógica de gravedad y movimiento WASD
func _handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Obtenemos la dirección desde los inputs definidos en el mapa de entrada.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, walk_speed)
		velocity.z = move_toward(velocity.z, 0.0, walk_speed)

	move_and_slide()

## Interpola la posición del viewmodel para un efecto de retraso (Sway)
func _apply_viewmodel_sway(delta: float) -> void:
	if is_instance_valid(viewmodel_pivot):
		viewmodel_pivot.position.x = lerp(viewmodel_pivot.position.x, target_sway.x, delta * sway_smoothness)
		viewmodel_pivot.position.y = lerp(viewmodel_pivot.position.y, target_sway.y, delta * sway_smoothness)
		
		# Tilt lateral basado en el movimiento del jugador
		var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var target_tilt: float = input_dir.x * -0.05
		viewmodel_pivot.rotation.z = lerp(viewmodel_pivot.rotation.z, target_tilt, delta * sway_smoothness)
		
		# Retornamos el objetivo a cero gradualmente
		target_sway = target_sway.lerp(Vector2.ZERO, delta * sway_smoothness)

## Aplica un movimiento sinusoidal al caminar (Bobbing)
func _apply_head_bobbing(delta: float) -> void:
	if is_instance_valid(viewmodel_pivot):
		if is_on_floor() and velocity.length() > 0.1:
			var speed_ratio = velocity.length() / walk_speed
			bob_time += delta * bob_frequency * speed_ratio
			var bob_offset_y: float = sin(bob_time) * bob_amplitude
			var bob_offset_x: float = cos(bob_time / 2.0) * (bob_amplitude * 0.8) # Lissajous en X
			viewmodel_pivot.position.y += bob_offset_y * delta
			viewmodel_pivot.position.x += bob_offset_x * delta
		else:
			# Resetear tiempo si estamos quietos
			bob_time = 0.0
			viewmodel_pivot.position.y = lerp(viewmodel_pivot.position.y, 0.0, delta * sway_smoothness)
			viewmodel_pivot.position.x = lerp(viewmodel_pivot.position.x, 0.0, delta * sway_smoothness)
