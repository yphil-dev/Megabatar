extends Node3D

@onready var sparks = $Sparks
@onready var flash = $Flash
@onready var fire = $Fire
@onready var smoke = $Smoke
@onready var timer = $Timer

signal explosion_finished

var has_finished = false

func _ready():
	sparks.emitting = false
	flash.emitting = false
	fire.emitting = false
	smoke.emitting = false

func finish():
	if has_finished:
		return
	has_finished = true
	explosion_finished.emit()
	queue_free()

func _on_timer_timeout():
	finish()

func _on_visible_on_screen_notifier_3d_screen_exited():
	finish()
