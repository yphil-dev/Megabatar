extends Node3D

@onready var timer = $Timer
@onready var bubbles = $Bubbles

func _ready():
	bubbles.emitting = true

func _on_timer_timeout():
	queue_free()
