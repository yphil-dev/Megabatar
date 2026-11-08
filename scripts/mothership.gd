extends Node3D

@onready var Spawner = preload("res://scenes/spawner.tscn")
# @onready var world = get_node("/root/World")
# const Sound = preload("res://scenes/sound_manager.tscn")
# @onready var snd = get_node("/root/World/SoundManager")

const BULLET = preload("res://scenes/weapons/laser.tscn")
const LIFE = preload("res://scenes/life.tscn")
const DEATH_FIRE = preload("res://scenes/fire.tscn")
const MOTHERSHIP_BREAKUP = preload("res://scripts/mothership_breakup.gd")

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

signal exploded(explosion)
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

    health = 50 if Globals.is_debug else (Globals.level_num + 1) * 250
    Globals.boss_health = health
    
    spawn_point = $SpawnPoint if name != "Mother" else $armature/SpawnPoint
    
    $EntranceHorn.play()
    if !$EntranceHorn.finished.is_connected($Music.play):
        $EntranceHorn.finished.connect($Music.play)

    Globals.say("Name is {name} and health is {health}".format({"name":name, "health":health}))

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
    # Globals.say("This mothership's name is {name} and its health level is {health}".format({"name":name, "health":health}))
    Globals.boss_health = health
    if health <= 0 and !has_exploded:
        has_exploded = true
        Globals.boss_health = 0

        if name != "Mother":
            var breakup = MOTHERSHIP_BREAKUP.new()
            get_node("/root/World").add_child(breakup)
            breakup.start(self)

        spawn_death_fire(global_position)
        var explosion = Globals.explode(Vector3(global_transform.origin.x, global_transform.origin.y, global_transform.origin.z - 5), 4, 10)
        exploded.emit(explosion)
        queue_free()
    
func spawn_death_fire(origin: Vector3):
    var is_mother = name == "Mother"
    var offsets = [
        Vector3(0, 0, -24),
        Vector3(0, 2, -12),
        Vector3(0, 0, 0),
        Vector3(0, -2, 12),
        Vector3(0, 1, 24),
    ]
    var target_scales = [
        Vector3(10, 7, 16),
        Vector3(12, 8, 20),
        Vector3(16, 10, 26),
        Vector3(12, 8, 20),
        Vector3(10, 7, 16),
    ]

    if is_mother:
        offsets = [
            Vector3(0, 0, -34),
            Vector3(0, 4, -23),
            Vector3(0, -3, -12),
            Vector3(0, 0, 0),
            Vector3(0, 3, 12),
            Vector3(0, -4, 23),
            Vector3(0, 1, 34),
        ]
        target_scales = [
            Vector3.ONE * 32,
            Vector3.ONE * 38,
            Vector3.ONE * 46,
            Vector3.ONE * 58,
            Vector3.ONE * 46,
            Vector3.ONE * 38,
            Vector3.ONE * 32,
        ]

    for index in range(offsets.size()):
        var fire = DEATH_FIRE.instantiate()
        get_node("/root/World").add_child(fire)
        fire.global_position = origin + offsets[index]
        fire.scale = Vector3(2, 1.5, 3)

        var particles = fire.get_node("FireParticles")
        particles.local_coords = false
        particles.process_material = particles.process_material.duplicate()
        particles.process_material.gravity = Vector3.ZERO
        particles.process_material.emission_sphere_radius = 1.5

        particles.process_material.direction = Vector3.RIGHT
        particles.process_material.spread = 180.0
        particles.process_material.initial_velocity_min = 5.0
        particles.process_material.initial_velocity_max = 10.0

        if is_mother:
            particles.amount = 100
            particles.process_material.color = Color(3.5, 0.7, 2.4, 1)
            particles.process_material.initial_velocity_min = 9.0
            particles.process_material.initial_velocity_max = 18.0

        var tween = fire.create_tween()
        tween.tween_property(fire, "scale", target_scales[index], 0.35).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
        tween.tween_interval(3.0)
        tween.tween_property(fire, "scale", Vector3.ZERO, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
        tween.tween_callback(fire.queue_free)

func _fire():
    $Charge.finished.disconnect(_fire)
    for muzzle in $Guns.get_children():
        var laser = BULLET.instantiate()
        laser.is_mothership = true
        if name == "Mother":
            laser.is_mother = true
        laser.away = true
        laser.speed = 80.0
        laser.laser_scale = muzzle.scale
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

    if !$Charge.finished.is_connected(_fire):
        $Charge.finished.connect(_fire)

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
    $SpawnShuttle.play()
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
    
