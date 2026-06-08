extends Node

func _ready() -> void:
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("Assets/Textures"):
		dir.make_dir_recursive("Assets/Textures")
	
	var src_path = "C:/Users/ANTONIO/.gemini/antigravity/brain/16cc0e00-e9da-401f-ab17-1321d22df8aa/dirt_texture_1780345406933.png"
	var dest_path = "res://Assets/Textures/dirt_texture.png"
	var file_bytes = FileAccess.get_file_as_bytes(src_path)
	if file_bytes.size() > 0:
		var out_file = FileAccess.open(dest_path, FileAccess.WRITE)
		out_file.store_buffer(file_bytes)
		out_file.close()
		print("Texture copied successfully!")
	else:
		print("Failed to read source file.")
	
	get_tree().quit()
