extends Node3D

var tween

@onready var heart = $LifeBox/Heart
@onready var world = get_node("/root/World")
@onready var Bubble = preload("res://scenes/explosions/bubble.tscn")

var life_type

func _ready():

    $LifeBox/Blast.visible = false
    $LifeBox/Missile.visible = false
    $LifeBox/Heart.visible = true

    match life_type:
        "life":
            $LifeBox/Heart.material_override.albedo_color = Color.RED
        "health":
            $LifeBox/Heart.material_override.albedo_color = Color.BLUE
        "missiles":
            $LifeBox/Missile.visible = true
            $LifeBox/Heart.visible = false
        "blast":
            $LifeBox/Blast.visible = true
            $LifeBox/Heart.visible = false
            
    tween = get_tree().create_tween()
    tween.set_trans(Tween.TRANS_BACK)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:x", - 25, 6.0).as_relative()
    tween.parallel().tween_property(self, "position:y", global_transform.origin.y + 30, 6.0)

func pop():
    tween.stop()
    # $LifeBox/Bubble.visible = false
    var bubble = Bubble.instantiate()
    world.add_child(bubble)
    bubble.global_transform.origin = global_transform.origin
    bubble.get_node("AnimationPlayer").play("pop")

    if life_type == "life":
        Globals.say("New ship, good luck!")
        Globals.lives += 1
    elif life_type == "health":
        Globals.say("Ship repaired, good luck!")
        Globals.health += 10
    elif life_type == "missiles":
        Globals.say("You have missiles now!")
        Globals.has_missiles = true
    elif life_type == "blast":
        Globals.say("You have BLAST now!")
        Globals.has_blast = true
        
    queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited():
    queue_free()
