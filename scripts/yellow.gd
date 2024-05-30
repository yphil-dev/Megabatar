extends RigidBody3D

const MOVEMENT_SPEED = 500.0
const AMPLITUDE_UP = 2.0
const AMPLITUDE_DOWN = 2.0
const MOVEMENT_FORCE = 500.0

var health = 10
#export (float) var MAX_HEALTH = 100

var initial_y = 0  # Initial Y position
var time_elapsed = 0  # Time elapsed since the start
var direction = 1  # 1 for moving up, -1 for moving down
var current_amplitude = AMPLITUDE_UP  # Current amplitude of movement

func react(arg):
	print("arg:", arg)
	
func _ready():
	initial_y = global_transform.origin.y  # Store the initial Y position

func oscillate(delta):
	# Update time elapsed
	time_elapsed += delta

	# Calculate the target Y position based on amplitude and direction
	var target_y = initial_y + current_amplitude * direction

	# Calculate the force to apply for oscillation
	var force = Vector3(0, current_amplitude * direction * MOVEMENT_FORCE, 0)

	# Apply the force to move the object
	apply_impulse(force * delta)

	# Check if the object reaches the target Y position
	if abs(global_transform.origin.y - target_y) < 0.1:
		# Change direction when reaching the target position
		direction *= -1
		# Change amplitude based on direction
		if direction == 1:
			current_amplitude = AMPLITUDE_UP
		else:
			current_amplitude = AMPLITUDE_DOWN

func move(delta):
	var target_x = -10  # Define the target X position towards the negative X axis

	# Calculate the movement direction based on the target X position
	var movement_direction = sign(target_x - global_transform.origin.x)

	# Calculate the force to apply for movement
	var force = Vector3(movement_direction * MOVEMENT_FORCE, 0, 0)

	# Apply the force to move the object
	apply_impulse(force * delta)

func _process(delta):
	if health <= 0:
		queue_free()
	oscillate(delta)
	move(delta)
