extends SceneTree

func _init():
	var reader = ZIPReader.new()
	var err = reader.open("res://Assets/Farm.zip")
	if err == OK:
		var files = reader.get_files()
		var dirs = {}
		for f in files:
			var split = f.split("/")
			if split.size() > 0:
				dirs[split[0]] = true
		print("Root folders in Farm.zip:")
		for d in dirs.keys():
			print("- " + d)
	else:
		print("Failed to open Farm.zip")
	quit()
