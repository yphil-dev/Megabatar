extends Camera3D

func _ready():
    start_camera_rotation()

func start_camera_rotation():
    var tween = get_tree().create_tween()
    
    # Define the rotation for the circular path (360 degrees around Y-axis)
    var target_rotation = global_transform.basis.rotated(Vector3.UP, 2 * PI)
    
    tween.tween_property(self, "global_transform:basis", target_rotation, 5) # 5 seconds
    tween.set_trans(Tween.TRANS_LINEAR)
    tween.set_ease(Tween.EASE_IN_OUT)
    
    # Restart the tween to make the camera keep rotating
    tween.tween_callback(start_camera_rotation)

func _process(_delta):
    pass
