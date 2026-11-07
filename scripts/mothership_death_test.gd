extends Node3D

const MOTHERSHIP_NAMES = [
    "Platform",
    "Hammer",
    "Retractor",
    "Pince",
    "Mother",
]

@onready var enemies = $Enemies
@onready var camera = $Camera3D
@onready var status_label = $CanvasLayer/StatusLabel

var current_index = 0
var current_mothership
var destruction_in_progress = false

func _ready():
    enemies.mothership_destroyed.connect(_on_mothership_destroyed)
    await spawn_current_mothership()

func _unhandled_input(event):
    if event.is_action_pressed("ui_cancel"):
        get_tree().quit()
    elif event.is_action_pressed("ui_accept"):
        destroy_current_mothership()

func spawn_current_mothership():
    Globals.level_num = current_index
    enemies.spawn_mothership(current_index)
    current_mothership = enemies.mothership
    current_mothership.set_process(false)

    await get_tree().process_frame

    for tween in get_tree().get_processed_tweens():
        tween.kill()

    current_mothership.global_position = Vector3(35, 0, 0)
    destruction_in_progress = false
    update_status("Press Space or Enter to destroy it")

func destroy_current_mothership():
    if destruction_in_progress or !is_instance_valid(current_mothership):
        return

    destruction_in_progress = true
    update_status("Destruction in progress...")

    current_mothership.health = 0
    current_mothership._process(0.0)

func _on_mothership_destroyed():
    current_index = (current_index + 1) % MOTHERSHIP_NAMES.size()
    await get_tree().create_timer(0.5).timeout
    await spawn_current_mothership()

func shock_wave(_mothership):
    camera.shake()

func say_something(text):
    status_label.text = str(text)

func update_status(instruction):
    status_label.text = "%s — %s\nEsc quits" % [MOTHERSHIP_NAMES[current_index], instruction]
