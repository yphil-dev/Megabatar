extends Node3D

signal explosion_finished

@export var is_mother = false

var has_finished = false

func _ready():
    scale = Vector3.ONE * 3.0

    if is_mother:
        scale = Vector3.ONE * 5.5
        $Fire.amount = 36
        $Smoke.amount = 32
        $Sparks.amount = 140
        $Debris.amount = 45
        $Fire.process_material = $Fire.process_material.duplicate()
        $Fire.process_material.color = Color(1.25, 0.3, 1.65, 1)
        $Smoke.process_material = $Smoke.process_material.duplicate()
        $Smoke.process_material.color = Color(0.45, 0.16, 0.55, 0.8)
        $Flash.process_material = $Flash.process_material.duplicate()
        $Flash.process_material.color = Color(3.5, 1.2, 3.2, 1)
        $OmniLight3D.light_color = Color(1, 0.25, 0.75)
        $OmniLight3D.omni_range = 180.0

    $Flash.restart()
    $Fire.restart()
    $Smoke.restart()
    $Sparks.restart()
    $Debris.restart()
    $DeathSound.play()

    var light_energy = 32.0 if is_mother else 20.0
    var light_tween = create_tween()
    light_tween.tween_property($OmniLight3D, "light_energy", light_energy, 0.04)
    light_tween.tween_property($OmniLight3D, "light_energy", 0.0, 0.65).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

    await get_tree().create_timer(5.5).timeout
    finish()

func finish():
    if has_finished:
        return
    has_finished = true
    explosion_finished.emit()
    queue_free()
