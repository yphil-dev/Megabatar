extends Node3D

@onready var Spawner = preload("res://scenes/spawner.tscn")
# @onready var world = get_node("/root/World")
# const Sound = preload("res://scenes/sound_manager.tscn")
# @onready var snd = get_node("/root/World/SoundManager")

const BULLET = preload("res://scenes/weapons/laser.tscn")
const LIFE = preload("res://scenes/life.tscn")

# const Blob = preload("res://scenes/enemies/shuttles/blob_rigid.tscn")
const ball_drone = preload("res://scenes/enemies/shuttles/ball_drone.tscn")

var Shuttles = [
    preload("res://scenes/enemies/shuttles/golgot.tscn"),
    preload("res://scenes/enemies/shuttles/minos.tscn"),
    preload("res://scenes/enemies/shuttles/flatter.tscn"),
    preload("res://scenes/enemies/shuttles/flatter.tscn"),
    preload("res://scenes/enemies/shuttles/ball_drone.tscn"),
]

var health:int = 0

signal exploded
var has_exploded = false

func play_motor_start():
    $MotorStart.play()
    # play_snd("MotorStart")
    # $MotorLoop.play()
    # $MotorStop.stop()
    # $MotorStart.play()

func play_motor_loop():
    $MotorLoop.play()
    # play_snd("MotorLoop")
    # print("playing MotorLoop")
    # $MotorStop.stop()
    # $MotorStart.stop()
    # $MotorLoop.play()

func play_motor_stop():
    $MotorStop.play()
    # play_snd("MotorStop")
    # $MotorLoop.stop()
    # $MotorStart.stop()
    # $MotorStop.play()

func play_music_loop():
    if $EntranceHorn.finished.is_connected($Music.play):
        $EntranceHorn.finished.disconnect($Music.play)
    $Music.play()
   
var spawn_point

func _ready():

    health = (Globals.level_num + 1) * 100
    
    spawn_point = $SpawnPoint if name != "Mother" else $armature/SpawnPoint
    
    $EntranceHorn.play()
    $EntranceHorn.finished.connect($Music.play)

    Globals.say("This mothership's name is {name} and its health level is {health} Level + 1 is {h}".format({"name":name, "health":health, "h":Globals.level_num + 1 * 6}))

    play_motor_loop()
    global_transform.origin = Vector3(70,0,0)
    var tween = get_tree().create_tween()
    tween.tween_callback(play_motor_loop)
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position:x", -20, 2.5).as_relative()
    tween.tween_callback(play_motor_start)
    tween.tween_callback(move)
    
func _process(_delta):
    if health <= 0:
        Globals.explode(Vector3(global_transform.origin.x, global_transform.origin.y, global_transform.origin.z - 5), 4, 10)
        exploded.emit()
        queue_free()
    
func _fire():
    $Charge.finished.disconnect(_fire)
    for muzzle in $Guns.get_children():
        var laser = BULLET.instantiate()
        laser.is_mothership = true
        laser.away = true
        laser.speed = 80.0
        laser.shoot_direction = "home"
        laser.set_shoot_type("hostile")
        get_parent().add_child(laser)
        laser.global_transform.origin = muzzle.global_transform.origin
    
func set_exhaust(n):
    if name != "Mother":
        for exhaust in $Exhaust.get_children():
            var tween = get_tree().create_tween()
            tween.tween_property(exhaust, "scale", Vector3(n,n,n), 1.5)
        
func move():
    var tween = get_tree().create_tween()
    tween.tween_callback(play_motor_stop)
    tween.tween_callback(fire_and_maybe_spawn)
    tween.tween_callback(play_motor_start)

    tween.tween_interval(2)
    tween.tween_callback(play_motor_start)
    tween.tween_property(self, "position:y", -10, 1.5)
    tween.tween_callback(play_motor_stop)
    tween.tween_callback(set_exhaust.bind(1))
    tween.tween_callback(fire_and_maybe_spawn)
    tween.tween_property(self, "position:z", randi_range(-20, 20), 2.0).set_trans(Tween.TRANS_BACK)
    tween.tween_interval(3)
    tween.tween_callback(play_motor_start)
    tween.tween_callback(set_exhaust.bind(3))
    tween.tween_property(self, "position:y", 5, 1.5)
    tween.tween_callback(play_motor_stop)
    tween.tween_callback(set_exhaust.bind(1))
    tween.tween_callback(fire_and_maybe_spawn)
    tween.tween_interval(4)
    tween.tween_callback(play_motor_start)
    tween.tween_property(self, "position:y", 14, 1.5)
    tween.tween_callback(set_exhaust.bind(3))
    tween.tween_callback(play_motor_stop)
    tween.tween_callback(set_exhaust.bind(1))
    tween.tween_callback(fire_and_maybe_spawn)
    tween.tween_callback(stop)

func stop():
    var tween = get_tree().create_tween()
    tween.tween_callback(play_motor_stop)
    tween.tween_property(self, "rotation_degrees:x", 1, 0.5)
    tween.tween_property(self, "rotation_degrees:x", -1, 0.5)
    tween.tween_property(self, "rotation_degrees:x", 0, 1).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(move)

var mouth_material
    
func fire_and_maybe_spawn():
    var shuttles_spawned = get_tree().get_nodes_in_group("Shuttles")
    $Charge.play()

    for muzzle in $Guns.get_children():

        mouth_material = muzzle.get_surface_override_material(0)

        var tween = get_tree().create_tween()
        tween.tween_property(mouth_material, "albedo_color", Color.FIREBRICK, 1.7)
        tween.parallel().tween_property(mouth_material, "emission", Color.FIREBRICK, 1.7)
        tween.tween_callback(reset_mouth_color)
        
    $Charge.finished.connect(_fire)
    # _fire()
    if shuttles_spawned.size() < (Globals.level_num + 1) * 2:
        spawn_shuttle()

func reset_mouth_color():

    var tween = get_tree().create_tween()
    tween.tween_property(mouth_material, "albedo_color", Color.BLACK, 0.7)
    tween.parallel().tween_property(mouth_material, "emission", Color.BLACK, 0.7)

func spawn_spawner():
    var spawner = Spawner.instantiate()
    add_child(spawner)
    spawner.global_transform.origin = spawn_point.global_transform.origin
    
func spawn_shuttle():
    # play_snd("SpawnShuttle")
    spawn_spawner()
    var shuttle = Shuttles[Globals.level_num].instantiate()
    # var shuttle = ball_drone.instantiate()
    shuttle.action = "attack"
    shuttle.is_parked = false
    get_parent().add_child(shuttle)
    shuttle.start_moving()

    var spos = spawn_point.global_transform.origin
    var new_pos = Vector3(spos.x, spos.y + 1, spos.z)
    shuttle.global_transform.origin = new_pos

var life_spawned = false

func spawn_life(life_type):
    if not life_spawned:
        var life = LIFE.instantiate()
        life.life_type = life_type
        get_parent().add_child(life)
        life.global_transform.origin = global_transform.origin
        life_spawned = true
    
