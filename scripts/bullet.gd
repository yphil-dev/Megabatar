extends RigidBody3D


var speed = 3.0
var damage = 1

var shoot_direction :String = "upleft"
# var away = true
var shoot_type
var is_mothership
var length = 30.0

var color = Color.TEAL


func _ready():
	global_transform.origin.z = 0
	if shoot_type == "hostile":
		color = Color.LIME_GREEN
		$Collision.collision_mask = 1
	else:
		color = Color.TEAL
		$Collision.collision_mask = 2

	if is_mothership:
		color = Color.GREEN
		# damage += 50
		# mass = 50.0

# 	$MeshInstance3D.set_surface_override_material(0, $MeshInstance3D.get_surface_override_material(0).duplicate())
# 	$MeshInstance3D.get_surface_override_material(0).albedo_color = color
# 	$MeshInstance3D.get_surface_override_material(0).emission = color
	
	var dir
		
	linear_velocity.y = 0
	linear_velocity.z = 0

	var right = transform.basis.x
	var up = transform.basis.y

	if shoot_direction == "away":
		dir = transform.basis.x 
	elif shoot_direction == "home":
		dir = -transform.basis.x 
	elif shoot_direction == "upleft":
		# dir = (-right + up).normalized()
		dir = (-right + up)
		dir = Vector3(-5,5,0)

	linear_velocity = dir * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_shoot_type(type):
	shoot_type = type

