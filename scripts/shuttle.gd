extends Node3D

var pos
var health = 2
const damage = 15
const PRICE = 15
const BULLET = preload("res://scenes/weapons/laser.tscn")
const LIFE = preload("res://scenes/life.tscn")
var life_spawned = false
@onready var world = get_node("/root/World")

@export var laser_color:Color

var action
var is_parked = true

func _process(_delta):
    if health <= 0:
        Globals.explode(Vector3(global_transform.origin), 2, 2)
        Globals.score += PRICE
        if is_in_group("RewardHealth"):
            spawn_life("health")
        elif is_in_group("RewardMissiles"):
            spawn_life("missiles")
        elif is_in_group("RewardBlast"):
            spawn_life("blast")

        queue_free()

func _ready():
    if pos: global_transform.origin = pos
    $ViewportCamera.visible = false

var tween
    
func start_moving():
    await get_tree().create_timer(1.0).timeout
    $HitBox/Exhaust.visible = true
    $AudioStreamPlayer.play()
    tween = create_tween()
    tween.tween_property(self, "position:y", 18.0, 1.0)
    tween.parallel().tween_property(self, "rotation_degrees:x", -2, 0.05).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(self, "rotation_degrees:x", 2, 0.05).set_trans(Tween.TRANS_SINE)
    # tween.parallel().tween_property(self, "position:z", -22, 0.5)

    if action == "attack":
        tween.tween_property(self, "position:x", -15.0 if action == "attack" else 0.1, 1.0).set_trans(Tween.TRANS_BACK).as_relative()
        tween.tween_callback(attack if action == "attack" else guard)
    
func spawn_life(life_type):
    if not life_spawned:
        var life = LIFE.instantiate()
        life.life_type = life_type
        world.add_child(life)
        life.global_transform.origin = global_transform.origin
        life_spawned = true

func guard():
    $HitBox/Exhaust.visible = true
    $AudioStreamPlayer.play()
    tween = get_tree().create_tween()
    tween.tween_property(self, "position:y", Globals.spos.y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(self, "rotation_degrees:x", -2, 0.2).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(self, "rotation_degrees:x", 2, 0.05).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(_fire)
    tween.connect("finished", guard)

func attack():
    tween = create_tween()
    tween.set_ease(Tween.EASE_OUT_IN)
    var rand_y = randf_range(-5.0, 5.0)
    tween.tween_property(self, "position:y", rand_y, 1.0).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(self, "position:x", randf_range(-1.0, -5.0), 1.0).as_relative()
    tween.parallel().tween_callback(set_exhaust.bind(3, 1.0))

    tween.tween_property(self, "position:y", Globals.spos.y, 1.5).set_trans(Tween.TRANS_BACK)
    tween.parallel().tween_callback(set_exhaust.bind(Globals.spos.y / 10, 1.5))

    if !Globals.is_2d:
        tween.tween_property(self, "position:z", randi_range(-20, 20), 1.0).set_trans(Tween.TRANS_BACK)

    tween.tween_callback(set_exhaust.bind(1, 0.1))
    tween.tween_property(self, "rotation_degrees:z", -2, 0.05).set_trans(Tween.TRANS_SINE)
    tween.tween_callback(shoot.bind(3))
    tween.tween_property(self, "rotation_degrees:z", 0, 0.3).set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "position:x", randf_range(-5.0, 15.0), 1.0).as_relative()
    tween.parallel().tween_property(self, "rotation_degrees:x", 0, 0.5)
    # tween.parallel().tween_callback(set_exhaust.bind(3, 1.5))
    tween.tween_property(self, "position:y", Globals.spos.y, 1.5).set_trans(Tween.TRANS_BACK)
    tween.parallel().tween_callback(set_exhaust.bind(Globals.spos.y / 10, 0.5))

    if !Globals.is_2d:
        tween.tween_property(self, "position:z", Globals.spos.z, 0.5).set_trans(Tween.TRANS_BACK)
        tween.parallel().tween_property(self, "position:y", Globals.spos.y, 0.5).set_trans(Tween.TRANS_BACK)
        tween.parallel().tween_callback(set_exhaust.bind(Globals.spos.y / 10, 0.5))

    tween.tween_callback(shoot.bind(2))
    
    tween.tween_property(self, "position:x", 1.0, 1.0).as_relative()
    tween.parallel().tween_callback(set_exhaust.bind(2, 1.0))
    tween.tween_callback(stop)

func set_exhaust(power, time):
    pass
    # for exhaust in $HitBox/Exhaust.get_children():
    #     var e_tween = get_tree().create_tween()
    #     e_tween.tween_property(exhaust, "scale", Vector3(power,power,power), time)
    
func stop():
    tween = create_tween()
    tween.tween_property(self, "rotation_degrees:x", 5, 0.1)
    tween.tween_property(self, "rotation_degrees:x", -5, 0.1)
    tween.tween_property(self, "rotation_degrees:x", 0, 0.2).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_callback(set_exhaust.bind(1, 0.2))
    tween.tween_callback(attack)

func shoot(n):
    for i in range(n):
        _fire()
        await get_tree().create_timer(randf_range(0.05, 0.2)).timeout

func _fire():
    var laser = BULLET.instantiate()
    laser.color = laser_color
    laser.away = true
    laser.speed = 80.0
    laser.shoot_direction = "home"
    laser.set_shoot_type("hostile")
    world.add_child(laser)
    laser.global_transform.origin = $Muzzle.global_transform.origin

func _on_visible_on_screen_notifier_3d_screen_entered():
    if is_parked and !is_in_group("Grounded"):
        guard()

func _on_visible_on_screen_notifier_3d_screen_exited():
    queue_free()

func start_wave_type_attack():
    # await get_tree().create_timer(1.0).timeout
    $HitBox/Exhaust.visible = true
    $AudioStreamPlayer.play()

    # var shoot_tween = get_tree().create_tween().set_loops()
    # shoot_tween.tween_callback(shoot.bind(Globals.level_num + 2)).set_delay(1)
    
    var attack_tween = create_tween()
    attack_tween.tween_property(self, "position:x", -20, 1.5)
    attack_tween.tween_callback(shoot.bind(Globals.level_num + 2))
    attack_tween.tween_property(self, "position:x", -150, 2.5).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN).as_relative()
    # tween.parallel().tween_property(self, "rotation_degrees:z", randi_range(-5, 5), 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
    attack_tween.parallel().tween_property(self, "rotation_degrees:x", randi_range(180, 360), 7.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN)
    # tween.parallel().tween_property(self, "rotation_degrees:x", -180, 4.0).set_trans(Tween.TRANS_BACK)
