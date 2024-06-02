extends Node3D

var health = 5
const PRICE = 5
const LIFE = preload("res://scenes/life.tscn")
const BULLET = preload("res://scenes/weapons/fire_ball.tscn")

var has_shot = false
var pos_own := Vector3.ZERO
var rotated = false
var life_spawned = false

func _process(_delta):
    if health <= 0:
        Globals.explode(Vector3(global_transform.origin), 2, 2)
        Globals.score += PRICE
        if is_in_group("RewardHealth"):
            spawn_life("health")

        if is_in_group("RewardMissiles"):
            spawn_life("missiles")

        if is_in_group("RewardBlast"):
            spawn_life("blast")
            
        queue_free()

func spawn_life(life_type):
    if not life_spawned:
        var life = LIFE.instantiate()
        life.life_type = life_type
        get_parent().get_parent().add_child(life)
        life.global_transform.origin = global_transform.origin
        life_spawned = true

func _fire():
    var laser = BULLET.instantiate()
    var dir
    var speed = 2.0
    get_parent().add_child(laser)
    var m = $Muzzle.global_transform.origin

    laser.linear_velocity.y = 0
    laser.linear_velocity.z = 0

    if is_in_group("Down"):
        laser.global_transform.origin = Vector3(m.x, m.y + 1.0, m.z)
        dir = Vector3(-5,5,0)
        laser.rotation = Vector3(0,0,-52.5)
    else:
        laser.global_transform.origin = Vector3(m.x, m.y - 1.0, m.z)
        dir = Vector3(-5,-5,0)
        laser.rotation = Vector3(0,0,30.5)
    
    laser.linear_velocity = dir * speed
    
var tween
func point_guns():
    tween = get_tree().create_tween()
    tween.tween_property($CannonHitBox/Guns, "rotation:z", -0.5, 1.0)
    # tween.stop()
    tween.tween_callback(stop_gun_rotation)

func stop_gun_rotation():
    tween.stop()
    rotated = true
    _fire()
    
func _on_visible_on_screen_notifier_3d_screen_entered():
    if !rotated:
        point_guns()

