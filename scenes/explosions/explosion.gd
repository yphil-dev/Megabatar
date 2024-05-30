extends Node3D

@onready var sparks = $Sparks
@onready var flash = $Flash
@onready var fire = $Fire
@onready var smoke = $Smoke
@onready var timer = $Timer

func _ready():
	sparks.emitting = false
	flash.emitting = false
	fire.emitting = false
	smoke.emitting = false

func _on_timer_timeout():
	queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited():
	queue_free()
