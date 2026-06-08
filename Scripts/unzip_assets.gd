extends Node

func _ready() -> void:
	print("Starting extraction...")
	var zips = [
		"res://Assets/Farm.zip",
		"res://Assets/kenney_food-kit.zip",
		"res://Assets/kenney_nature-kit.zip"
	]
	
	for zip_path in zips:
		var dest_folder = zip_path.replace(".zip", "")
		var dir = DirAccess.open("res://")
		var rel_dest = dest_folder.replace("res://", "")
		if not dir.dir_exists(rel_dest):
			dir.make_dir_recursive(rel_dest)
		
		var reader = ZIPReader.new()
		var err = reader.open(zip_path)
		if err != OK:
			print("Failed to open " + zip_path)
			continue
			
		for file_path in reader.get_files():
			var full_dest = dest_folder + "/" + file_path
			if file_path.ends_with("/"):
				var rel_full_dest = full_dest.replace("res://", "")
				if not dir.dir_exists(rel_full_dest):
					dir.make_dir_recursive(rel_full_dest)
			else:
				var file_bytes = reader.read_file(file_path)
				var base_dir = full_dest.get_base_dir().replace("res://", "")
				if not dir.dir_exists(base_dir):
					dir.make_dir_recursive(base_dir)
				
				var out_file = FileAccess.open(full_dest, FileAccess.WRITE)
				if out_file:
					out_file.store_buffer(file_bytes)
					out_file.close()
		
		reader.close()
		print("Extracted " + zip_path)
	
	print("All extractions complete.")
	get_tree().quit()
