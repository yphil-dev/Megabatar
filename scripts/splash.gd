extends Node3D

@onready var Intro = preload("res://scenes/intro.tscn")

signal splash_finished

func _process(_delta):
    if Input.is_action_just_pressed("quit"):
        get_tree().quit()

    if Input.is_action_just_pressed("shoot_lasers"):
        get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_animation_player_animation_finished(anim_name):
    var intro_video = Intro.instantiate()
    await get_tree().create_timer(0.5).timeout
    add_child(intro_video)
