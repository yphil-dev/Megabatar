extends Node3D

@onready var world = get_node("/root/World")

var mothership
var destroyer
var shuttle
var shuttle_entered = false

signal mothership_destroyed
signal wave_is_over

var is_wave_over = false

var Bits = [
    preload("res://scenes/enemies/bits/bit_cone.tscn"),
    preload("res://scenes/enemies/bits/bit_electric_orb_big.tscn"),
    preload("res://scenes/enemies/bits/bit_pyramid.tscn"),
    preload("res://scenes/enemies/bits/bit_electric_orb_small.tscn"),
    preload("res://scenes/enemies/bits/bit.tscn"),
]

var Shuttles = [
    preload("res://scenes/enemies/shuttles/minos.tscn"),       #1
    preload("res://scenes/enemies/shuttles/golgot.tscn"),      #2
    preload("res://scenes/enemies/shuttles/flatter.tscn"),     #3
    preload("res://scenes/enemies/shuttles/flatter.tscn"),     #4
    preload("res://scenes/enemies/shuttles/ball_drone.tscn"),  #5
]

var Motherships = [
    preload("res://scenes/enemies/motherships/platform.tscn"),  #1
    preload("res://scenes/enemies/motherships/hammer.tscn"),    #2
    preload("res://scenes/enemies/motherships/retractor.tscn"), #3
    preload("res://scenes/enemies/motherships/pince.tscn"),     #4
    preload("res://scenes/enemies/motherships/mother.tscn"),    #5
]

var shuttle_count = 0

var music_loop

func _process(_delta):
    shuttle_count = 0
    for child in get_children():
        if child.is_in_group("Shuttles"):
            shuttle_count += 1

    # Globals.say("{ns} shuttles ; over:{wo} entered: {se}".format({"ns":shuttle_count, "wo":is_wave_over, "se":shuttle_entered}))
            
    if shuttle_count == 0 and !is_wave_over and shuttle_entered:
        is_wave_over = true
        shuttle_entered = false
        wave_is_over.emit()
        
    Globals.say("{d} dead".format({"d":Globals.dead_wave_enemies}))
# func fade_out_music():
#   var tween = create_tween()
#   tween.tween_property($Wave01, "volume_db", -80, 2)
#   $Wave01.stop()
        
func wave_loop_start():
    Globals.dead_wave_enemies = 0
    $MusicLoops.get_child(Globals.level_num).play()
    
func wave_loop_stop():
    var loop = $MusicLoops.get_child(Globals.level_num)
    var tween = create_tween()
    tween.tween_property(loop, "volume_db", -80, 2)
    loop.stop()
    
func spawn_mothership(n):
    mothership = Motherships[n].instantiate()
    mothership.exploded.connect(_on_mothership_exploded)
    add_child(mothership)
    
var dead_bits_count = 0

func spawn_bits(n):
    shuttle_entered = true
    is_wave_over = false
    shuttle_count = 0
    # $MusicLoops.get_child(Globals.level_num).play()
    for i in range(n):
        spawn_bit(i)
        await get_tree().create_timer(0.2).timeout
    
func spawn_bit(n):
    var bit = Bits[Globals.level_num].instantiate()
    set_reward_flag(bit)
    add_child(bit)
    bit.global_transform.origin = Vector3(55,0,0)
    bit.is_dead.connect(_on_death)

var was_rewarded = false

func _on_death():
    dead_bits_count += 1
    
func set_reward_flag(bit):
    if dead_bits_count >= 6 and !was_rewarded:
        bit.is_rewarded = true
        was_rewarded = true
    
func _on_mothership_exploded():
    
    for child in get_children():
        if child.is_in_group("Shuttles"):
            child.health = 0
            
    world.shock_wave(mothership)

    mothership_destroyed.emit()
    
func spawn_shuttles(number_of_shuttles):
    shuttle_entered = true
    is_wave_over = false
    shuttle_count = 0
    for i in range(number_of_shuttles):
        spawn_shuttle(i)
        await get_tree().create_timer(0.2).timeout

func spawn_shuttle(y_offset):
    shuttle = Shuttles[Globals.level_num].instantiate()
    var initial_offset = -20
    shuttle.is_parked = false
    add_child(shuttle)
    shuttle.global_transform.origin = Vector3(40, initial_offset + 4 * y_offset, 0)
    # shuttle.global_transform.origin = Vector3(45, 2 * y_offset, 0)
    shuttle.start_wave_type_attack()
