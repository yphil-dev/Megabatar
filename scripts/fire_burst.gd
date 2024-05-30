extends CharacterBody3D

@export var speed = 80.0  # Adjust the speed as needed
@export var steer_force = 250.0  # Adjust the steering force as needed

var spawn_position = null
var target = null

func _ready():
	if spawn_position:
		global_transform.origin = spawn_position.global_transform.origin

var direction = Vector3()
var drift_speed = 50
var chase_speed = 200
var current_speed = drift_speed


var looking_for_player = false
var aim_target = Vector3()

func _physics_process(delta):
	velocity = Vector3()
	#velocity += -current_speed * delta
	velocity.y = 0
	move_and_slide()

	$PlayerCompass.look_at(target.global_transform,Vector3.UP)

	if looking_for_player:
		current_speed = chase_speed
		$Head.rotation = lerp($Head.rotation,$PlayerCompass.rotation,delta*0.5)
	else:
		current_speed = drift_speed
		$Head.rotation = lerp($Head.rotation,$PlayerCompass.rotation,delta*0.05)

func _on_LookArea_body_entered(body):
	if body.is_in_group("Player"):
		looking_for_player = true

func _on_LookArea_body_exited(body):
	if body.is_in_group("Player"):
		looking_for_player = false
		
# Setter function to set the target body from exterior
func set_target_body(body):
	target = body

func set_spawn_position(muzzle_position):
	spawn_position = muzzle_position
