extends Node3D

signal scroll_finished

func _ready():
	$Music.play()
	
func _on_animation_player_animation_finished(anim_name):
	$Music.stop()
	emit_signal("scroll_finished")
	queue_free()
