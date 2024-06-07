extends Camera3D

var random_strengh = 1.0
var shake_fade = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength = 0.0

func shake():
    shake_strength = random_strengh

func _process(delta):

    if shake_strength > 0:
        shake_strength = lerpf(shake_strength, 0, shake_fade * delta)

    v_offset = random_offset()
    h_offset = random_offset()

func random_offset():
    return rng.randf_range(-shake_strength, shake_strength)
