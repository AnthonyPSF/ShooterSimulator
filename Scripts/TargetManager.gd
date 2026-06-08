extends Node3D

@onready var timer = $Timer
var target_scene = preload("res://Scenes/Target.tscn")
var rng = RandomNumberGenerator.new()

func _ready():
    rng.randomize()
    timer.wait_time = 1.5
    timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
    if target_scene == null:
        return
        
    var game_manager = get_node_or_null("/root/Main/GameManager")
    if game_manager and not game_manager.game_active:
        return
        
    var new_target = target_scene.instantiate()
    add_child(new_target)
    
    var random_x = rng.randf_range(-9.0, 9.0)
    var random_y = rng.randf_range(1.0, 6.0)
    var random_z = rng.randf_range(-9.0, 9.0)
    
    new_target.global_position = Vector3(random_x, random_y, random_z)
