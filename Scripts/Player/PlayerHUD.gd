extends CanvasLayer

var ammo_label: Label
var weapon_label: Label

func _ready():
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	var dot = ColorRect.new()
	dot.custom_minimum_size = Vector2(4, 4)
	dot.color = Color(1, 1, 1, 0.8)
	center.add_child(dot)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_bottom", 50)
	add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(vbox)
	
	ammo_label = Label.new()
	ammo_label.text = "0 / 0"
	ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ammo_label.add_theme_font_size_override("font_size", 48)
	vbox.add_child(ammo_label)
	
	weapon_label = Label.new()
	weapon_label.text = "..."
	weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	weapon_label.add_theme_font_size_override("font_size", 24)
	weapon_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(weapon_label)
	
	call_deferred("_connect_signals")

func _connect_signals():
	var wep_man = get_parent().get_node_or_null("HeadPivot/MainCamera/ViewmodelPivot/WeaponManager")
	if wep_man:
		wep_man.weapon_switched.connect(_on_weapon_switched)
		for w in wep_man.weapons:
			w.ammo_changed.connect(_on_ammo_changed)
			w.weapon_reloaded.connect(_on_weapon_reloaded)

func _on_ammo_changed(current: int, reserve: int):
	ammo_label.text = str(current) + " / " + str(reserve)
	if current <= int(reserve * 0.2) and current <= 10: # Si queda poco
		ammo_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	else:
		ammo_label.add_theme_color_override("font_color", Color.WHITE)

func _on_weapon_reloaded():
	ammo_label.add_theme_color_override("font_color", Color.WHITE)

func _on_weapon_switched(weapon_name: String):
	weapon_label.text = weapon_name
