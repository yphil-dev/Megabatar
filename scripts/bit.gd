extends Node3D

const LIFE = preload("res://scenes/life.tscn")
@onready var world = get_node("/root/World")

var health = 2
var PRICE = 1
signal is_dead
var is_rewarded = false
var life_spawned = false
var is_even = false

var damage = 2

func _ready():
    randomize()
    # if is_even:
    #     $Anim.play("r")
    # else:
    #     $Anim.play("r_2")
    
    var random_anim = randi() % 2

    if random_anim == 0:
        $Anim.play("r")
    else:
        $Anim.play("r_2")
        
func _process(_delta):
    if health <= 0:
        is_dead.emit()
        Globals.explode(Vector3(global_transform.origin), 6, 1)
        Globals.score += PRICE

        # spawn_life("health")
        
        if is_rewarded:
            spawn_life("health")

        Globals.dead_wave_enemies += 1

        queue_free()

func spawn_life(life_type):
    if not life_spawned:
        var life = LIFE.instantiate()
        life.life_type = life_type
        world.add_child(life)
        life.global_transform.origin = global_transform.origin
        life_spawned = true
