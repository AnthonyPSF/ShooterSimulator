extends StaticBody3D
class_name CropPlot

enum PlotState { UNPLANTED, PLANTED, WATERED }

var state: PlotState = PlotState.UNPLANTED
var current_crop_data: CropData = null
var growth_progress: float = 0.0
var current_stage: int = 0

@onready var mesh_instance = $MeshInstance3D
@onready var crop_visual = $CropVisual

var dry_mat = StandardMaterial3D.new()
var wet_mat = StandardMaterial3D.new()

func _ready():
	dry_mat.albedo_color = Color(0.3, 0.2, 0.1)
	wet_mat.albedo_color = Color(0.15, 0.1, 0.05)
	mesh_instance.material_override = dry_mat

func _process(delta):
	if state == PlotState.WATERED and current_crop_data != null:
		growth_progress += delta
		if growth_progress >= current_crop_data.grow_time_seconds:
			growth_progress = current_crop_data.grow_time_seconds
		
		# Update stage
		var progress_ratio = growth_progress / current_crop_data.grow_time_seconds
		var new_stage = int(progress_ratio * current_crop_data.stages)
		if new_stage >= current_crop_data.stages:
			new_stage = current_crop_data.stages - 1
			
		if new_stage != current_stage:
			current_stage = new_stage
			update_crop_visual()

func update_crop_visual():
	if current_crop_data == null or current_crop_data.meshes.size() == 0:
		return
	var mesh_index = min(current_stage, current_crop_data.meshes.size() - 1)
	crop_visual.mesh = current_crop_data.meshes[mesh_index]

func on_interact(player):
	var tool = player.current_tool
	if tool == "seed" and state == PlotState.UNPLANTED:
		if InventoryManager.remove_item("seed_basic", 1):
			# Load the BasicCrop from Resources
			current_crop_data = load("res://Resources/CropData/BasicCrop.tres")
			if current_crop_data:
				state = PlotState.PLANTED
				growth_progress = 0.0
				current_stage = 0
				update_crop_visual()
				print("Planted seed! Semillas restantes: ", InventoryManager.get_item_amount("seed_basic"))
		else:
			print("No tienes semillas!")
	elif tool == "water" and state == PlotState.PLANTED:
		state = PlotState.WATERED
		mesh_instance.material_override = wet_mat
		print("Watered plot!")
	elif tool == "harvest":
		if current_crop_data != null and growth_progress >= current_crop_data.grow_time_seconds:
			print("Harvested " + current_crop_data.crop_name + "!")
			InventoryManager.add_money(20) # Hardcoded value for now
			print("Dinero actual: ", InventoryManager.money)
			reset_plot()

func reset_plot():
	state = PlotState.UNPLANTED
	current_crop_data = null
	growth_progress = 0.0
	current_stage = 0
	crop_visual.mesh = null
	mesh_instance.material_override = dry_mat
