extends Node3D

@onready var music_slider = $Control/VBoxContainer/MusicSlider
@onready var sfx_slider = $Control/VBoxContainer/SFXSlider

var music_bus = AudioServer.get_bus_index("Music")
var sfx_bus = AudioServer.get_bus_index("SFX")

signal play_pressed
signal controls_pressed

func _ready():
    await get_tree().create_timer(0.5).timeout

    $Control/VBoxContainer/Buttons/Play.grab_focus()
    music_slider.value = Globals.music_volume
    AudioServer.set_bus_volume_db(music_bus, Globals.music_volume)
    sfx_slider.value = Globals.sfx_volume
    AudioServer.set_bus_volume_db(sfx_bus, Globals.sfx_volume)

func _on_quit_pressed():
    get_tree().quit()

func _on_play_pressed():
    play_pressed.emit()
    queue_free()

func _on_controls_pressed():
    controls_pressed.emit()
    # get_tree().change_scene_to_file("res://scenes/input_settings.tscn")
    
func _on_music_slider_drag_ended(value_changed):
    if value_changed:
        Globals.save_volume("music", music_slider.value)

func _on_music_slider_value_changed(value):
    AudioServer.set_bus_volume_db(music_bus, value)

func _on_sfx_slider_drag_ended(value_changed):
    if value_changed:
        Globals.save_volume("sfx", sfx_slider.value)    

func _on_sfx_slider_value_changed(value):
    AudioServer.set_bus_volume_db(sfx_bus, value)

func play_clang_sound():
    $Clang.play()
    
