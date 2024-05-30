extends RigidBody3D

@onready var mesh = $MeshInstance3D
@export var nickname = "Taurus"
const explosion = preload("res://scenes/explosions/explosion.tscn")
@onready var world = get_node("/root/World")

var health = 5
const PRICE = 5

@export var movement_speed := 1.0:
	set(new_speed):
		movement_speed = new_speed
	get:
		return movement_speed

@export var spawn_offset := 0.5:
	set(new_offset):
		spawn_offset = new_offset
	get:
		return spawn_offset

@onready var enemies = get_node("/root/World/Enemies")

func react(arg):
	print("arg:", arg)
	
func _ready():
# Check if the mesh has a surface override material and if it's properly assigned
	#mesh.material_override.albedo_color = Color.ORANGE
	global_transform.origin = enemies.global_transform.origin
	global_transform.origin.y += spawn_offset
	#$MeshInstance3D.set_surface_override_material(0, dissolve_material)
	mass = 0.001
	gravity_scale = 0

func move_left(delta):
	var movement = Vector3(-movement_speed, 0, 0) * delta
	translate(movement)

func _process(delta):
	if health <= 0:
		var hit = explosion.instantiate()
		var sparks = hit.get_node("Sparks")
		var flash = hit.get_node("Flash")
		var fire = hit.get_node("Fire")
		var smoke = hit.get_node("Smoke")
		world.add_child(hit)
		hit.global_transform.origin = Vector3(global_transform.origin)
		sparks.emitting = true
		fire.emitting = true
		smoke.emitting = true
		var fire_material = fire.get_process_material()
		fire_material.scale_min = 3
		fire_material.scale_max = 6
		var smoke_material = smoke.get_process_material()
		smoke_material.color = Color(0.5, 0.75, 0.2, 1.0)
		queue_free()
		Globals.score += PRICE
	move_left(delta)

func _on_visible_on_screen_notifier_3d_screen_exited():
	print("gone!")
	queue_free()
