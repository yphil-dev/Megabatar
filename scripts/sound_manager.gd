extends Node3D

func play_sound(sound_name):
	get_node(sound_name).play()
