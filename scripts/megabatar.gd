extends RigidBody3D

var health = 5
const PRICE = 5

const bubbles = preload("res://scenes/explosions/bubbles.tscn")
@export var nickname = "Megabatar"
@onready var world = get_node("/root/World")
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
	
func _process(delta):
	move_left(delta)
	if health <= 0:
		var hit = bubbles.instantiate()
		world.add_child(hit)
		hit.global_transform.origin = Vector3(global_transform.origin.x, global_transform.origin.y, 0.0)
		queue_free()
		Globals.score += PRICE
