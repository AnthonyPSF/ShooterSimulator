extends SceneTree

func _init():
	var packed_scene = load("res://Assets/Targets/standard_firing_target.glb")
	if not packed_scene:
		print("Could not load GLB")
		quit()
		return
		
	var node = packed_scene.instantiate()
	var meshes = []
	_find_meshes(node, meshes)
	
	var aabb = AABB()
	var first = true
	
	for mi in meshes:
		if mi is MeshInstance3D and mi.mesh:
			var mi_aabb = mi.mesh.get_aabb()
			# Transform by the node's transform
			# This is an approximation for AABB
			var xform = mi.global_transform
			# Actually, we should just get the transformed corners, but for simple targets it's usually axis-aligned.
			if first:
				aabb = mi_aabb
				first = false
			else:
				aabb = aabb.merge(mi_aabb)
				
	print("--- AABB INFO ---")
	print("Position: ", aabb.position)
	print("Size: ", aabb.size)
	print("End: ", aabb.end)
	print("-----------------")
	quit()

func _find_meshes(node: Node, meshes: Array):
	if node is MeshInstance3D:
		meshes.append(node)
	for child in node.get_children():
		_find_meshes(child, meshes)
