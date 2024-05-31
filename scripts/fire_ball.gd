extends RigidBody3D

var health = 5
const damage = 5

func _ready():

    var fire_color
    
    match Globals.level_num:
        0:
            fire_color = Color.GREEN
            $Fire.visible = false
            $Ball.visible = true
        1:
            fire_color = Color(0.471,0.784,0.902)
            $Fire.visible = false
            $Ball.visible = true
        2:
            fire_color = Color(0.801,0.643,0.901)
            $Fire.visible = true
            $Ball.visible = false
        3:
            fire_color = Color(1,0.439,0)
            $Fire.visible = true
            $Ball.visible = false
        4:
            $Fire.visible = true
            $Ball.visible = false

    $Fire.process_material.set("color", fire_color)
   
    for child in $Ball.get_children():
        for spike in child.get_children():
            if spike.name != "AnimationPlayer":
                spike.material_override.albedo_color = Color.ORANGE
                spike.material_override.emission_energy_multiplier = 10
    
func _process(_delta):
    if health <= 0:
        queue_free()
        
func _on_body_entered(body):
    if body.name != "ShipHitBox":
        Globals.health -= damage
    if body.name != "CannonHitBox":
        queue_free()

func _on_visible_on_screen_notifier_3d_screen_exited():
    queue_free()

func set_color():
    $Fire.process_material.set("color", Color.GREEN)
    pass
