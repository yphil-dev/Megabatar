extends Control

var world = preload("res://scenes/world.tscn")

signal finished

# func _ready():
# 	# await get_tree().create_timer(0.5).timeout
# 	$Video.play()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

	if Input.is_action_just_pressed("shoot_lasers"):
		get_tree().change_scene_to_file("res://scenes/world.tscn")
		
func _on_video_stream_player_finished():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

