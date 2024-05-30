extends Control

@onready var world = get_node("/root/World")

@onready var button = $Buttons/ResumeButton

func _ready():
	button.focus_mode = Control.FOCUS_ALL
	button.grab_focus()
	
func _on_quit_button_pressed():
	print("quit!")
	get_tree().quit()

func _on_resume_button_pressed():
	world.toggle_pause_menu()
