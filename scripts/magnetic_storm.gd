extends Node3D

func _ready():
    $VisibleOnScreenNotifier3D.screen_exited.connect(plop)
    var tween = get_tree().create_tween().set_loops()
    tween.tween_callback(move).set_delay(1)

func plop():
    Globals.say("plop!")
    print("storm dead")
    queue_free()

func move():
    global_transform.origin.y = randf_range(-50, 50)

