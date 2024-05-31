extends Node3D

@onready var Ship = preload("res://scenes/ship.tscn")
@onready var GameOn = preload("res://scenes/game_on.tscn")
@onready var Spawner = preload("res://scenes/spawner_ship.tscn")
@onready var Enemies = preload("res://scenes/enemies.tscn")

var Walls = [
    preload("res://scenes/scenery/walls_02-tech.tscn"),        #1
    preload("res://scenes/scenery/walls_02-semi_granit.tscn"), #2
    preload("res://scenes/scenery/walls_02-semi_forest.tscn"), #3
    preload("res://scenes/scenery/walls_01-granit.tscn"),      #4
    preload("res://scenes/scenery/walls_02-forest.tscn"),      #5
]

@onready var pause_menu = $PauseMenu

@onready var Lives = preload("res://scenes/lives.tscn")

@onready var shock_wave_color_rect = $ScreenControl/CanvasLayer/ShockWaveColorRect

var paused = false
var mothership
var enemies
var alive = false
var wall
var spawner
var is_debug = false

signal switched_cams
    
func _ready():
    _play_music_intro()

    Globals.level_num = 3
    is_debug = true
    
    var game_on = GameOn.instantiate()
    add_child(game_on)
    game_on.controls_pressed.connect(show_controls_overlay)
    game_on.play_pressed.connect(before)

    enemies = Enemies.instantiate()
    add_child(enemies)

    $AnimShipParade.play("parade")
    $EnterSpace.play()
    $AnimShipParade.animation_finished.connect($EnterSpace.stop.unbind(1))

    $Cameras/CameraMain.current = true
    $Cameras/CameraRear.current = false
    
func before():
    fade_music_out()
    $AnimShipGo.animation_finished.connect(phase_one.unbind(1))
    $AnimShipGo.play("go")
    $EnterSpace.play()
    
func phase_one():

    ui_on()
    say_something("MegaBatar " + Globals.VERSION)

    lives.visible = true
    if !alive:
        spawn(true)
        alive = true

    Globals.is_2d = true
    ship.reset_position()
    ship.crosshair("hide")

    $Cameras/CameraMain.current = true
    $Cameras/CameraRear.current = false
    
    $SpeedingStars.visible = true
    say_something("Phase One, Level " + str(Globals.level_num + 1))
    enemies.spawn_bits((Globals.level_num + 1) * 10 if !is_debug else 2)

    enemies.wave_loop_start()
    enemies.wave_is_over.connect(phase_half)
    
func phase_half():
    ship.crosshair("hide")
    say_something("Phase Half, Level " + str(Globals.level_num + 1))
    enemies.wave_is_over.disconnect(phase_half)
    enemies.is_wave_over = true
    enemies.shuttle_entered = false
    enemies.spawn_shuttles(10)
    enemies.wave_is_over.connect(phase_two)

func phase_two():
    ship.crosshair("hide")
    say_something("Phase Two, Level " + str(Globals.level_num + 1))
    enemies.wave_loop_stop()
    enemies.wave_is_over.disconnect(phase_two)
    enemies.is_wave_over = true
    enemies.shuttle_entered = false
    wall = Walls[Globals.level_num].instantiate()
    $Wall.add_child(wall)
    wall.scroll_finished.connect(phase_three)

func phase_three():
    lives.visible = false
    Globals.is_2d = false

    switch_cams($Cameras/CameraMain, $Cameras/CameraRear)
    switched_cams.connect(ship.crosshair.bind("show"))
    # ship.crosshair("show")
        
    say_something("Phase Three, Level " + str(Globals.level_num + 1))
    # wall.scroll_finished.disconnect(phase_three)
    enemies.spawn_mothership(Globals.level_num)
    enemies.mothership_destroyed.connect(level_up)
    ship.reset_position()
    
func level_up():
    if Globals.level_num == 4:
        Globals.game_over_title = "You Win"
        Globals.game_over_chapo = "Here's a sandwich and a beer ; Be at your combat post tomorrow 6AM sharp"
        get_tree().change_scene_to_file("res://scenes/game_over.tscn")
        return

    enemies.mothership_destroyed.disconnect(level_up)
    Globals.level_num += 1

    await get_tree().create_timer(2.5).timeout

    phase_one()

func switch_cams(from, to):
    var from_gt = from.global_transform
    var from_fov = from.fov

    var cam_tween = create_tween()
    cam_tween.tween_property(from, "global_transform", to.global_transform, 3.0)
    cam_tween.parallel().tween_property(from, "fov", to.fov, 3.0)
    cam_tween.tween_callback(reset_cam.bind(from, to, from_gt, from_fov))
    
func reset_cam(from, to, gt, fov):
    from.current = false
    to.current = true
    from.global_transform = gt
    from.fov = fov
    switched_cams.emit()

func _play_music_intro():
    $MusicIntro.play()
    $MusicIntro.finished.connect($MusicLoop.play)

func show_controls_overlay():
    $ControlsOverlay.visible = true

func fade_music_out():
    var intro_tween = create_tween()
    intro_tween.tween_property($MusicIntro, "volume_db", -60, 2.5)
    var loop_tween = create_tween()
    loop_tween.tween_property($MusicLoop, "volume_db", -60, 2.5)

var lives

func ui_on():
    lives = Lives.instantiate()
    add_child(lives)
    lives.global_transform.origin = Vector3(46.392,25.252,2.602)
    $Hud.visible = true
    $FacingStars.visible = false
    $OpeningScreenShip.visible = false
    $ControlsOverlay.visible = false
    
func toggle_pause_menu():
    if paused:
        pause_menu.hide()
        get_tree().paused = false
    else:
        pause_menu.show()
        pause_menu.button.grab_focus()
        get_tree().paused = true

    paused = !paused

func debug_camera():
    $Cameras/CameraMain.current = false
    $Cameras/CameraRear.current = true

func _process(_delta):

    if Input.is_action_just_pressed("pause"):
        if $ControlsOverlay.visible:
            $ControlsOverlay.visible = false
        else:
            toggle_pause_menu()
        
    if  Globals.health <= 0:
        $Cameras/CameraMain.shake()
        $Cameras/CameraRear.shake()
        Input.start_joy_vibration(0, 0, 0.8, .5)
        Globals.lives -= 1
        spawn(false)
        
    if Globals.lives == 0 or Input.is_action_just_pressed("quit"):
        get_tree().change_scene_to_file("res://scenes/game_over.tscn")

    if Input.is_action_just_pressed("back"):
        $ControlsOverlay.visible = false

    if Input.is_action_just_pressed("debug"):
        debug_camera()

    if Input.is_action_just_pressed("blast"):
        if Globals.has_blast:
            blast()

func get_all_children(in_node,arr:=[]):
    arr.push_back(in_node)
    for child in in_node.get_children():
        arr = get_all_children(child,arr)
    return arr

func blast():
    shock_wave($Center)
    
    var all_children = get_all_children(self)
    
    for child in all_children:
        if child.is_in_group("Enemies"):
            var notifier = child.get_node_or_null("VisibleOnScreenNotifier3D")
            if notifier:
                if notifier.is_on_screen():
                    child.health -= 50

    Globals.has_blast = false
    
func spawn_spawner():
    spawner = Spawner.instantiate()
    ship.add_child(spawner)

var ship

func spawn(first_spawn):
    Globals.health = 100
    ship = Ship.instantiate()

    ship.crosshair("hide" if Globals.is_2d else "show")
        
    spawn_spawner()

    if !first_spawn:
        await get_tree().create_timer(1.2).timeout
        
    $Player.add_child(ship)
    ship.global_transform.origin.x = -35

func to_2D(vector3):
    return $Cameras/CameraMain.unproject_position(vector3)

var shock_wave_material

func shock_wave(enemy):
    Input.start_joy_vibration(0, 0, 0.8, .5)
    $Cameras/CameraMain.shake()
    $Cameras/CameraRear.shake()
    var projection = to_2D(enemy.position) / (get_window().size as Vector2)
    print("projection", projection)
    shock_wave_material = shock_wave_color_rect.get_material()
    shock_wave_material.set_shader_parameter("center", projection)
    shock_wave_color_rect.visible = true
    var tween = get_tree().create_tween()
    tween.tween_property(shock_wave_material, "shader_parameter/size", 1.0, 2.0)
    tween.tween_callback(hide_shader_rect)

func hide_shader_rect():
    shock_wave_material.set_shader_parameter("center", Vector2(0.5, 0.5))
    shock_wave_material.set_shader_parameter("size", 0.0)
    shock_wave_color_rect.visible = false

func say_something(t):
    $Hud/BottomText/HBoxContainer2/BottomTextLabel.text = t
    
