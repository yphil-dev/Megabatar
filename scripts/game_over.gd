extends Node3D

@onready var score_value = $VBoxContainer/HBoxContainer2/ScoreValue
@onready var high_score_value = $VBoxContainer/HBoxContainer3/HighScoreValue

func _ready():
    $yPhilOffTheGrid.play()
    var score = Globals.score
    var high_score = Globals.high_score
    high_score_value.text = str(high_score)
    score_value.text = str(score)
    $VBoxContainer/HBoxContainer4/VBoxContainer2/PatreonButton.grab_focus()
    $VBoxContainer/HBoxContainer/VBoxContainer/Title.text = Globals.game_over_title
    $VBoxContainer/HBoxContainer/VBoxContainer/Chapo.text = Globals.game_over_chapo
    
func _process(_delta):
    if Input.is_action_just_pressed("quit"):
        get_tree().quit()

func _on_y_phil_button_pressed():
    OS.shell_open("https://yphil.gitlab.io/")

func _on_patreon_button_pressed():
    OS.shell_open("https://www.patreon.com/yphil/")

func _on_ko_fi_button_pressed():
    OS.shell_open("https://ko-fi.com/yphil/")

func _on_libera_pay_button_pressed():
    OS.shell_open("http://liberapay.com/yphil")
