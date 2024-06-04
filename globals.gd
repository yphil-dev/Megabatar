extends Node

const SAVE_PATH = "user://megabatar.cfg"
const Explosion = preload("res://scenes/explosions/explosion.tscn")
# @onready var LIVES = get_node("/root/World/Lives")

const VERSION = "v0.3b"

signal wave_over

signal first_wave_over
signal second_wave_over
signal third_wave_over

@onready var lives = 3

var health : int = 100:
    set(n):
        if n > health:
            print("health:", health)
            print("n:", n)
            # explode(Vector3(0,0,0), 9, 10)
        health = n
    get:
        return health


var spos

var is_2d = true

var level_num = 0

var score : int = 0:
    set(n):
        score = n
        if score > high_score:
            Globals.high_score = score
            save_high_score(score)
    get:
        return score

var high_score : int = 0

var game_over_title = "Game Over"
var game_over_chapo = "You failed, and now we're all gonna die"
        
var rocket_charge : float = 0.0

var r_rocket_charge : float = 0.0
var l_rocket_charge : float = 0.0

var laser_charge : float = 0.0

var music_volume
var sfx_volume
var config
var has_missiles = false
var has_blast = false

func _ready():
    # save_high_score(1)
    high_score = load_high_score()
    # save_volume("music", 50)
    music_volume = load_volume("music")
    sfx_volume = load_volume("sfx")
    
func save_high_score(n):
    config.set_value("stats", "high_score", n)
    config.save(SAVE_PATH)

func load_high_score():
    config = ConfigFile.new()
    var err = config.load(SAVE_PATH)
    if err != OK:
        save_high_score(0)
        return 0
    high_score = int(config.get_value("stats", "high_score", 0))
    # print("high_score ", high_score)
    return high_score

func load_volume(type):
    var err = config.load(SAVE_PATH)
    if err != OK:
        save_volume("music", -1.0)
        save_volume("sfx", -1.0)
        return 0
    music_volume = config.get_value("preferences", "music_volume", -1.0)
    sfx_volume = config.get_value("preferences", "sfx_volume", -1.0)

    # print("volume: ", music_volume)

    return music_volume if type == "music" else sfx_volume
    
func save_volume(type, value):
    config.set_value("preferences", type + "_volume", value)
    config.save(SAVE_PATH)
    
func explode(coords, force, damage):
    # Function body
    var explosion = Explosion.instantiate()
    # var sound = Sound.instantiate()
    var sparks = explosion.get_node("Sparks")
    var splatter = explosion.get_node("Splatter")
    var flash = explosion.get_node("Flash")
    var fire = explosion.get_node("Fire")
    var smoke = explosion.get_node("Smoke")
    var flash_material = flash.get_process_material()
    var sparks_material = sparks.get_process_material()
    var splatter_material = splatter.get_process_material()
    var fire_material = fire.get_process_material()
    # var smoke_material = smoke.get_process_material()
    var world = get_node("/root/World")
    # world.add_child(sound)
    world.add_child(explosion)
    explosion.global_transform.origin = coords


    var explosion_sound
    
    if force == 1: # laser impact
        sparks.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound4")
        explosion_sound.pitch_scale = randf_range(0.5, 2.0)
    elif force == 2: # Shuttles and cannons destruction
        flash.emitting = true
        fire.emitting = true
        sparks.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound1")
        explosion_sound.pitch_scale = randf_range(0.5, 2.0)
        flash_material.scale_min = 1
        flash_material.scale_max = damage * 3

        fire_material.scale_min = 4
        fire_material.scale_max = damage * 3

        fire_material.color = Color(5.00,2.00,1.00,1.00)
        fire.lifetime = 1.0
        fire.amount = 26
        fire_material.gravity = Vector3(0, 1, 0)
        
    elif force == 3: # Rocket impact
        flash.emitting = true
        fire.emitting = true
        sparks.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound1")
        flash_material.scale_min = 1
        flash_material.scale_max = damage * 4
        fire_material.scale_max = damage * 4
        fire.lifetime = 6.0
    elif force == 4: # Motherships destruction
        flash.emitting = true
        fire.emitting = true
        sparks.emitting = true
        smoke.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound2")
        flash_material.scale_min = 2
        flash_material.scale_max = damage * 5
        fire_material.scale_max = damage * 5
        fire.lifetime = 6.0 
    elif force == 5:
        sparks.visible = true
        sparks.emitting = true
        smoke.emitting = false
        fire.emitting = false
    elif force == 6: # Bit destruction
        flash.emitting = true
        sparks.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound3")
    elif force == 7: # Mother impact
        flash.emitting = true
        flash_material.scale_min = 2
        flash_material.scale_max = 8
        fire.emitting = true
        var impacts = explosion.get_node("MotherImpacts")
        var children = impacts.get_children()
        var random_index = randi() % children.size()
        
        explosion_sound = children[random_index]
        
        # explosion.ExplosionSound2.play()
        fire_material.scale_min = 4
        fire_material.scale_max = 16
        fire_material.color = Color.RED
        fire.lifetime = 2.0
        fire.amount = 6.0
        fire_material.gravity = Vector3(0, -6, 0)
        # sparks_material.scale_min = 1
        # sparks_material.scale_max = damage
    elif force == 8: # Ship destruction
        flash.emitting = true
        fire.emitting = true
        sparks.emitting = true
        # smoke.emitting = true
        explosion_sound = explosion.get_node("ExplosionSound1")
        flash_material.scale_min = 2
        flash_material.scale_max = damage * 5
        fire_material.scale_max = damage * 5
        fire.lifetime = 6.0 
    elif force == 9: # Ship healing
        explosion_sound = explosion.get_node("Heal")

        
    if force != 5:
        explosion_sound.play()
       
func plus_health(n):
    health = health + n if health <= 100 else 100
    
# Define a function to find a named node recursively
func find_named_node(root_node: Node, name_to_find: String) -> Node:
    # Check if the current node is the one we're looking for
    if root_node.name == name_to_find:
        return root_node

    # If the current node is not the one we're looking for, search its children
    for i in range(root_node.get_child_count()):
        var child_node = root_node.get_child(i)
        var found_node = find_named_node(child_node, name_to_find)
        if found_node != null:
            return found_node

    # If the named node is not found in this branch of the tree, return null
    return null

func get_root_node(node):
    if node.get_parent().name == "World":
        return node
    return node.get_parent()

func say(t):
    var world = get_node("/root/World")
    world.say_something(t)
