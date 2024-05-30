extends RigidBody3D

var health = 5
const PRICE = 5

@onready var visible_on_screen_notifier_3d = $VisibleOnScreenNotifier3D
const explosion = preload("res://scenes/explosions/explosion.tscn")
@onready var world = get_node("/root/World")
@export var nickname = "Prism"
@onready var enemies = get_node("/root/World/Enemies")

@export var movement_speed := 0.5:
	set(new_speed):
		movement_speed = new_speed
	get:
		return movement_speed

@export var spawn_offset := 0.5:
	set(new_offset):
		spawn_offset = new_offset
	get:
		return spawn_offset


func _ready():
	global_transform.origin = enemies.global_transform.origin
	global_transform.origin.y += spawn_offset
	mass = 0.001
	gravity_scale = 0

func move_left(delta):
	var movement = Vector3(-movement_speed, 0, 0) * delta
	translate(movement)

func react(arg):
	#$MeshInstance3D.material_override.albedo_color = Color.ORANGE
	print("arg:", arg)
	
	
func _process(delta):
	#visible_on_screen_notifier_3d.screen_exited.connect(queue_free)
	if health <= 0:
		Globals.explode(Vector3(global_transform.origin), 2, "enemy")
		queue_free()
		Globals.score += PRICE
	
	move_left(delta)

func _on_visible_on_screen_notifier_3d_screen_exited():
	print("Prisme gone")
	if !is_queued_for_deletion():
		queue_free()

#func _on_timer_timeout():
	#print("Prisme gone")
	#queue_free()


