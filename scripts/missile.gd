extends Node3D

var damage = 50
var target = null

var fired = false

@onready var exhaust = $Area3D/Fire

func _on_timer_timeout():
    if fired:
        queue_free()
    
func _on_area_3d_body_entered(body):

    Globals.say("body: {x}".format({"x":body}))

    if body.owner.is_in_group("Walls"):
        Globals.explode(global_transform.origin, 2, 30)
        queue_free()

    if fired:
        Globals.explode(global_transform.origin, 2, 30)
        if "health" in body.owner:
            body.owner.health -= damage

func set_target_body(body):
    target = body

func fire():
    fired = true
    $MissileIgnition.play()
    var tween = get_tree().create_tween()
    tween.tween_property(self, "position:x", 110.0, 1.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
    tween.parallel().tween_property(self, "position:y", 0.6, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN).as_relative()
    tween.parallel().tween_property(exhaust, "scale", Vector3(1.5,1.5,1.5,), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
    tween.tween_callback(queue_free)
    
func _on_visible_on_screen_notifier_3d_screen_exited():
    if fired:
        queue_free()
