extends RigidBody3D

const explosion = preload("res://scenes/explosions/explosion.tscn")
const bubbles = preload("res://scenes/explosions/bubbles.tscn")

@onready var world = get_node("/root/World")

# @onready var m_laser_sound = $Laser

var speed = 80.0
var damage = 1

var shoot_direction = "away"
var away = true
var shoot_type
var is_mothership
var length = 30.0

var color:Color

func _ready():
    $VisibleOnScreenNotifier3D.connect("screen_exited", func(): queue_free())
        
    if Globals.is_2d:
        global_transform.origin.z = 0
    
    if shoot_type == "hostile":
        $LaserSound1.play()
        $Mesh.scale = Vector3(85.0, 4.0, 4.0)
        color = Color.RED
        $Collision.collision_mask = 1
    else:
        if !is_mothership:
            $LaserSound2.play()
        $Mesh.scale = Vector3(185.0, 4.0, 4.0)
        color = color if color else Color.IVORY
        $Collision.collision_mask = 2 | 8
        # $Collision.collision_mask = 4

    if is_mothership:
        # $LaserSound2.play()
        $LaserSound3.play()
        $Mesh.scale = Vector3(260.0, 10.0, 25.0)
        color = Color.RED
        # damage += 50
        # mass = 50.0

    $Mesh.set_surface_override_material(0, $Mesh.get_surface_override_material(0).duplicate())
    $Mesh.get_surface_override_material(0).albedo_color = color
    $Mesh.get_surface_override_material(0).emission = color
    
    var dir = transform.basis.x if away else -transform.basis.x
        
    linear_velocity.y = 0
    linear_velocity.z = 0

    $VisibleOnScreenNotifier3D.screen_exited.connect(queue_free)

    var right = transform.basis.x
    var up = transform.basis.y

    if shoot_direction == "away":
        dir = transform.basis.x 
    elif shoot_direction == "home":
        dir = -transform.basis.x 
    elif shoot_direction == "upleft":
        dir = (-right + up).normalized()
        rotation = Vector3(0,0,40.3)
    
    linear_velocity = dir * speed
    
func _on_timer_timeout():
    queue_free()

func _on_area_3d_body_entered(body):

    # print("Hit!: ", body.name)

    if is_mothership:
        damage = (Globals.level_num + 1) * 10
        
    if body.name == "MotherBody":
        var og = body.global_transform.origin
        Globals.explode(Vector3(og.x - 5,og.y,og.z), 7, 3)
        queue_free()
        
    if body.name == "LifeBox":
        body.get_parent().pop()
        queue_free()
        
    if body.owner.is_in_group("Walls"):
        var g = global_transform.origin
        Globals.explode(Vector3(g.x - 7.0, g.y, g.z), 1, 2)
        queue_free()
        
    if "health" in body.owner:
        body.owner.health -= damage
        
    if "health" in body:
        body.health -= damage

    if body.owner.name == "Ship":
        Globals.health -= damage
        if is_mothership:
            Globals.explode(Vector3(global_transform.origin), 2, damage)
        else:
            Globals.explode(Vector3(global_transform.origin), 1, damage)

    if body.owner.is_in_group("Enemies") and shoot_type != "hostile":
        if !body.owner.is_in_group("Bits") and !body.owner.is_in_group("Motherships"):
            Globals.explode(Vector3(global_transform.origin), 1, damage)
        elif body.owner.is_in_group("Motherships") and shoot_type != "hostile":
            Globals.explode(Vector3(global_transform.origin), 3, damage)
            
    queue_free()

func set_shoot_type(type):
    shoot_type = type

func _on_visible_on_screen_notifier_3d_screen_exited():
    print("exited!")
    queue_free()
