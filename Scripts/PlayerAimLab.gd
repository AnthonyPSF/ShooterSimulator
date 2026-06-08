extends CharacterBody3D

const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
var current_speed = WALK_SPEED
var mouse_sensitivity = 0.002

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var raycast = $Head/Camera3D/RayCast3D

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        head.rotate_x(-event.relative.y * mouse_sensitivity)
        head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

    if Input.is_action_just_pressed("ui_cancel"):
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
        else:
            shoot()

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= 9.8 * delta

    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    current_speed = SPRINT_SPEED if Input.is_physical_key_pressed(KEY_SHIFT) else WALK_SPEED
    var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
    else:
        velocity.x = move_toward(velocity.x, 0, current_speed)
        velocity.z = move_toward(velocity.z, 0, current_speed)

    move_and_slide()

func shoot():
    if raycast.is_colliding():
        var target = raycast.get_collider()
        if target and target.has_method("hit"):
            target.hit()
