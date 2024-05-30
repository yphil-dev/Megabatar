extends Node3D

func _ready():
	print("Wave Name: ", name)
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
