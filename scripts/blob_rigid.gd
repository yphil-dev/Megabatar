extends RigidBody3D

var health = 5
const PRICE = 5

const bubbles = preload("res://scenes/explosions/blobs.tscn")
@export var nickname = "Megabatar"
@onready var world = get_node("/root/World")
@onready var enemies = get_node("/root/World/Enemies")

var state_machine

@export var movement_speed := 0.5:
    set(new_speed):
        movement_speed = new_speed
    get:
        return movement_speed

@export var spawn_offset := 0.5:
    set(new_offset):
        spawn_offset = new_offset
    get:
        return spawn_offset
        
func _ready():
    # apply_impulse(Vector3(-20, 10, 0), Vector3(0,0,0.05))
    var tween = create_tween()
    tween.tween_property(self, "position:x", -38, 0.6)
    tween.tween_property(self, "position:z", randi_range(-20, 20), 1.0).set_trans(Tween.TRANS_BACK)
    tween.parallel().tween_property(self, "scale", Vector3(1,1,1), 0.6)
    tween.tween_callback(move)

func move():
    # var move_tween = create_tween()
    # move_tween.tween_property(self, "position:x", -110, 2.0)
    # tween.tween_callback(move)
    apply_impulse(Vector3(-10, 5, 0), Vector3(0,0,0))
    pass
    
func _process(delta):
    # var move_tween = create_tween()
    # move_tween.tween_property(self, "scale", Vector3(2, 2, 2), 0.2)
    # move_tween.tween_callback(queue_free)
    # apply_force(Vector3(-50, 35, 0), Vector3(0,0,0.05))
    if health <= 0:
        var hit = bubbles.instantiate()
        world.add_child(hit)
        hit.global_transform.origin = Vector3(global_transform.origin.x, global_transform.origin.y, 0.0)
        var tween = create_tween()
        tween.tween_property(self, "scale", Vector3(2, 2, 2), 0.2)
        tween.tween_callback(queue_free)
        # queue_free()
        Globals.score += PRICE
