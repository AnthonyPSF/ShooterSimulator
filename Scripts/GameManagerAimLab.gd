extends Node

signal game_over

var score = 0
var time_left = 60.0
var game_active = true

var shots_fired: int = 0
var hits: int = 0

@onready var score_label = $"../UI/ScoreLabel"
@onready var time_label = $"../UI/TimeLabel"

func _ready():
	# Conectar dinámicamente con las armas del jugador
	var player = get_node_or_null("../Player")
	if player:
		# Ruta basada en la arquitectura PlayerController actual
		var weapon_manager = player.get_node_or_null("HeadPivot/MainCamera/ViewmodelPivot/WeaponManager")
		if weapon_manager:
			for weapon in weapon_manager.get_children():
				if weapon.has_user_signal("bullet_fired") or weapon.has_signal("bullet_fired"):
					weapon.bullet_fired.connect(_on_bullet_fired)

func _process(delta):
	if game_active:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			game_active = false
			game_over.emit()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		update_ui()

func _on_bullet_fired():
	if game_active:
		shots_fired += 1

func _on_target_destroyed():
	if game_active:
		hits += 1
		score += 100
		update_ui()

func update_ui():
	if score_label:
		score_label.text = "Score: " + str(score)
	if time_label:
		time_label.text = "Time: " + str(int(time_left))

func get_accuracy() -> float:
	if shots_fired == 0:
		return 0.0
	return (float(hits) / float(shots_fired)) * 100.0
