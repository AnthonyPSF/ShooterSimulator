extends Node3D

@export var concurrent_targets: int = 4
@export var grid_columns: int = 4
@export var grid_rows: int = 3
@export var grid_spacing: float = 2.0
@export var grid_offset: Vector3 = Vector3(0, 3, 0)

var target_scene = preload("res://Scenes/GridshotTarget.tscn")
var rng = RandomNumberGenerator.new()

var grid_cells: Array[Vector3] = []
var occupied_cells: Dictionary = {}

func _ready():
	rng.randomize()
	_generate_grid()
	_initial_spawn()

func _generate_grid():
	grid_cells.clear()
	var start_x = -(grid_columns - 1) * grid_spacing / 2.0
	var start_y = -(grid_rows - 1) * grid_spacing / 2.0
	
	for x in range(grid_columns):
		for y in range(grid_rows):
			var local_pos = grid_offset + Vector3(start_x + x * grid_spacing, start_y + y * grid_spacing, 0)
			var pos = global_transform * local_pos
			grid_cells.append(pos)

func _initial_spawn():
	var spawn_count = min(concurrent_targets, grid_cells.size())
	for i in range(spawn_count):
		spawn_target()

func spawn_target():
	var game_manager = get_node_or_null("/root/AimLab/GameManager")
	if game_manager and not game_manager.game_active:
		return
		
	var free_indices = []
	for i in range(grid_cells.size()):
		if not occupied_cells.has(i) or not occupied_cells[i]:
			free_indices.append(i)
			
	if free_indices.size() == 0:
		return
		
	var chosen_index = free_indices[rng.randi() % free_indices.size()]
	occupied_cells[chosen_index] = true
	
	var new_target = target_scene.instantiate()
	add_child(new_target)
	new_target.global_position = grid_cells[chosen_index]
	
	# Conexiones de señal
	new_target.target_destroyed.connect(func(): _on_target_destroyed(chosen_index))
	if game_manager:
		new_target.target_destroyed.connect(game_manager._on_target_destroyed)

func _on_target_destroyed(cell_index: int):
	occupied_cells[cell_index] = false
	# Reposición instantánea
	call_deferred("spawn_target")
