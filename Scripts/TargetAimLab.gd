extends Area3D

var points = 100

func _ready():
    add_to_group("targets")

func hit():
    var game_manager = get_node_or_null("/root/AimLab/GameManager")
    if game_manager and game_manager.has_method("add_score"):
        game_manager.add_score(points)
    queue_free()
