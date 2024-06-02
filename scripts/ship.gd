extends CharacterBody3D

const BULLET = preload("res://scenes/weapons/laser.tscn")
const ROCKET = preload("res://scenes/weapons/missile.tscn")
const EXPLOSION = preload("res://scenes/explosions/explosion.tscn")

@onready var world = get_node("/root/World")
@onready var fire_timer = $FireTimer
@onready var right_rocket_timer = $RightRocketTimer
@onready var left_rocket_timer = $LeftRocketTimer
@onready var damage_smoke = $ShipHitBox/Starship/DamageSmoke
@onready var coll_box = $ShipHitBox/CollisionBox

var rocket_right
var rocket_left

var current_enemy_index = 0
var current_enemy

const SPEED = 25.0
const ROTATION_ANGLE = 65.0
const ROTATION_SPEED = 3.0

var gravity = 0
var initial_rotation = rotation_degrees

var right_rocket_ready = false
var left_rocket_ready = false
var rockets_prepped = false

func _ready():
    if Globals.has_missiles:
        _prep_rockets()
        rockets_prepped = true
    
    var coll_m = coll_box.get_collision_mask()
    var masks = []
    for i in range(32):
        if coll_m & (1 << i) != 0:
            masks.append(i + 1)

    await get_tree().create_timer(2.5).timeout
    $ShipHitBox/CollisionBox.monitoring = true

func _fire_lasers():
            
    fire_timer.start()
    
    var bullet_left = BULLET.instantiate()
    bullet_left.away = true
    bullet_left.set_shoot_type("friendly")
    world.add_child(bullet_left)

    var bullet_right = BULLET.instantiate()
    bullet_right.away = true
    bullet_right.set_shoot_type("friendly")
    world.add_child(bullet_right)
    
    if !Globals.is_2d:
        bullet_left.global_transform = $ShipHitBox/GunMuzzleLeft.global_transform
        bullet_right.global_transform = $ShipHitBox/GunMuzzleRight.global_transform
    else:
        bullet_left.global_transform = $ShipHitBox/GunMuzzleCenter.global_transform
        bullet_right.global_transform = $ShipHitBox/GunMuzzleCenter.global_transform
        
func _prep_rockets():
    _prep_right_rocket()
    _prep_left_rocket()

func _prep_right_rocket():
    rocket_right = ROCKET.instantiate()
    if $ShipHitBox:
        $ShipHitBox.add_child(rocket_right)
        if $ShipHitBox/MissileMuzzleRight:
            rocket_right.global_transform = $ShipHitBox/MissileMuzzleRight.global_transform
    right_rocket_ready = true

func _prep_left_rocket():
    rocket_left = ROCKET.instantiate()
    if $ShipHitBox:
        $ShipHitBox.add_child(rocket_left)
        if $ShipHitBox/MissileMuzzleLeft:
            rocket_left.global_transform = $ShipHitBox/MissileMuzzleLeft.global_transform
    left_rocket_ready = true

func _fire_right_rocket():
    right_rocket_timer.start()
    if $ShipHitBox/MissileMuzzleRight:
        _fire_rocket(rocket_right, $ShipHitBox/MissileMuzzleRight.global_transform)
    right_rocket_ready = false

func _fire_left_rocket():
    left_rocket_timer.start()
    if $ShipHitBox/MissileMuzzleLeft:
        _fire_rocket(rocket_left, $ShipHitBox/MissileMuzzleLeft.global_transform)
    left_rocket_ready = false

func _fire_rocket(rocket, muzzle_transform):
    if rocket and muzzle_transform and world:
        rocket.reparent(world)
        rocket.global_transform = muzzle_transform
        rocket.fire()

func _fire_rockets():
    if Globals.has_missiles:
        if left_rocket_ready and right_rocket_ready:
            _fire_right_rocket()
        elif left_rocket_ready:
            _fire_left_rocket()
        elif right_rocket_ready:
            _fire_right_rocket()

func _physics_process(delta):
    Globals.spos = global_transform.origin

    if Globals.has_missiles and not rockets_prepped:
        _prep_rockets()
        rockets_prepped = true

    if Globals.has_missiles:
        _update_charge(right_rocket_timer)
        _update_charge(left_rocket_timer)

    _update_charge(fire_timer)

    if Globals.health <= 0:
        Globals.explode(Vector3(global_transform.origin), 3, 10)
        queue_free()

    damage_smoke.visible = Globals.health <= 50
    
    _handle_input()
    _update_movement(delta)

func crosshair(action):
    Globals.say("crosshair: {x}".format({"x":action}))
    match action:
        "show":
            $Crosshair.visible = true
            $Anim.play("crosshair_zoom")
        "hide":
            $Crosshair.visible = false
    
func _update_charge(timer):
    if timer.time_left > 0 and timer.time_left < timer.wait_time:
        var charge = reverse_number(map_range(timer.time_left, 0, timer.wait_time, 0, 100))
        if timer == right_rocket_timer:
            Globals.r_rocket_charge = charge
        elif timer == left_rocket_timer:
            Globals.l_rocket_charge = charge
        else:
            Globals.laser_charge = charge

func reverse_number(num: float) -> float:
    return 100 - num
    
func map_range(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
    return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)

func _handle_input():
    # if Input.is_action_just_pressed("select_next_enemy") or Input.is_action_just_pressed("select_prev_enemy"):
    #     _handle_enemy_selection()

    if Input.is_action_pressed("shoot_lasers") and fire_timer.time_left == 0:
        _fire_lasers()

    if Input.is_action_just_released("shoot_rockets"):
        _fire_rockets()

func _handle_enemy_selection():
    var enemies = get_tree().get_nodes_in_group("Shuttles")
    if enemies.size() > 0:
        if current_enemy_index >= 0 and current_enemy_index < enemies.size() - 1:
            var previous_enemy = enemies[current_enemy_index]
            var previous_selecter = Globals.find_named_node(Globals.get_root_node(previous_enemy), "Crosshair")
            if previous_selecter:
                previous_selecter.visible = false

        if Input.is_action_just_pressed("select_prev_enemy"):
            current_enemy_index = (current_enemy_index + 1) % enemies.size()
        elif Input.is_action_just_pressed("select_next_enemy"):
            current_enemy_index = (current_enemy_index - 1) % enemies.size()
            if current_enemy_index < 0:
                current_enemy_index = enemies.size() - 1

        var selected_enemy = enemies[current_enemy_index]
        current_enemy = selected_enemy
        var selecter = Globals.find_named_node(Globals.get_root_node(selected_enemy), "Crosshair")
        if selecter:
            selecter.visible = true

func _update_movement(delta):
    if Globals.is_2d:
        _update_movement_2d(delta)
    else:
        _update_movement_3d(delta)

func reset_position():
    rotation_degrees.x = 0
    global_transform.origin.z = 0
    global_transform.origin.x = -40
        
func _update_movement_2d(delta):
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, -input_dir.y, 0)).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.y = direction.y * SPEED
        var target_rotation = initial_rotation.x + ROTATION_ANGLE * -direction.y
        rotation_degrees.x = lerp(rotation_degrees.x, target_rotation, ROTATION_SPEED * delta)
        if global_position.x > 38:
            global_position.x = 38
        if global_position.x < -40:
            global_position.x = -40
        if global_position.y > 25:
            global_position.y = 25
        if global_position.y < -20:
            global_position.y = -20

    else:
        rotation_degrees.x = lerp(rotation_degrees.x, initial_rotation.x, ROTATION_SPEED * delta)
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.y = move_toward(velocity.y, 0, SPEED)

    velocity.z = 0
    move_and_slide()
    
func _update_movement_3d(delta):
    var input_dir = Input.get_vector("left", "right", "up", "down")
    var direction = (transform.basis * Vector3(input_dir.x, -input_dir.y, input_dir.y)).normalized()

    if direction:
        velocity.z = direction.x * SPEED
        velocity.y = direction.y * SPEED
        var target_rotation = initial_rotation.x + ROTATION_ANGLE * direction.x
        rotation_degrees.x = lerp(rotation_degrees.x, target_rotation, ROTATION_SPEED * delta)

        if global_position.z > 25:
            global_position.z = 25
        if global_position.z < -25:
            global_position.z = -25
        if global_position.y > 15:
            global_position.y = 15
        if global_position.y < -14:
            global_position.y = -14

    else:
        rotation_degrees.x = lerp(rotation_degrees.x, initial_rotation.x, ROTATION_SPEED * delta)
        velocity.z = 0
        velocity.y = 0

    velocity.x = 0
    move_and_slide()
    
func _on_area_3d_body_entered(body):

    # print("ship hit ", body.name)
    
    if body.name == "LifeBox":
        if body.get_parent():
            body.get_parent().pop()
        return

    if body.is_in_group("Enemies") or body.is_in_group("Walls"):
        if "damage" in body.get_parent():
            Globals.health -= body.get_parent().damage

        if "health" in body.get_parent():
            body.get_parent().health -= 30

        Globals.explode(Vector3(global_transform.origin), 2, 10)
        Input.start_joy_vibration(0, 0, 0.8, .5)
        
    if body.name == "MothershipBox" or body.is_in_group("Walls"):
        Globals.health = 0
    elif body.name == "ShuttleBox":
        Globals.health -= 5

func _on_right_rocket_timer_timeout():
    if Globals.has_missiles:
        _prep_right_rocket()

func _on_left_rocket_timer_timeout():
    if Globals.has_missiles:
        _prep_left_rocket()
