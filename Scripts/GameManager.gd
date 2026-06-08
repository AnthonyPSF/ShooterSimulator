extends Node

var score = 0
var time_left = 60.0
var game_active = true

@onready var score_label = $"../UI/ScoreLabel"
@onready var time_label = $"../UI/TimeLabel"

func _process(delta):
    if game_active:
        time_left -= delta
        if time_left <= 0:
            time_left = 0
            game_active = false
            print("Game Over! Score: ", score)
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        update_ui()

func add_score(points):
    if game_active:
        score += points
        update_ui()

func update_ui():
    if score_label:
        score_label.text = "Score: " + str(score)
    if time_label:
        time_label.text = "Time: " + str(int(time_left))
