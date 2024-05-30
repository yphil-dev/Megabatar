extends Control

@onready var world = get_node("/root/World")

@onready var button = $Buttons/ResumeButton

func _ready():
    button.focus_mode = Control.FOCUS_ALL
    button.grab_focus()
    
# func _process(_delta):
#     if Input.is_action_just_pressed("pause"):
#         world.toggle_pause_menu()

func _on_quit_button_pressed():
    get_tree().quit()
    # get_tree().change_scene_to_file("res://scenes/game_over.tscn")

func _on_resume_button_pressed():
    world.toggle_pause_menu()

func _on_controls_button_pressed():
    world.show_controls_overlay()
