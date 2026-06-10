extends Control

@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var hits_label = $Panel/VBoxContainer/HitsLabel
@onready var shots_label = $Panel/VBoxContainer/ShotsLabel
@onready var accuracy_label = $Panel/VBoxContainer/AccuracyLabel
@onready var restart_button = $Panel/VBoxContainer/RestartButton

func _ready():
	hide()
	restart_button.pressed.connect(_on_restart_pressed)
	
	var game_manager = get_node_or_null("/root/AimLab/GameManager")
	if game_manager:
		game_manager.game_over.connect(_on_game_over)

func _on_game_over():
	var gm = get_node("/root/AimLab/GameManager")
	score_label.text = "Score Final: " + str(gm.score)
	hits_label.text = "Aciertos: " + str(gm.hits)
	shots_label.text = "Balas Disparadas: " + str(gm.shots_fired)
	accuracy_label.text = "Precisión: %.1f%%" % gm.get_accuracy()
	show()

func _on_restart_pressed():
	get_tree().reload_current_scene()
