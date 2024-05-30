extends StaticBody3D

var health = 10
const PRICE = 50
const LIFE = preload("res://scenes/life.tscn")
var life_spawned = false

func _ready():
    $VisibleOnScreenNotifier3D.connect("screen_entered", _on_visible)
    $VisibleOnScreenNotifier3D.connect("screen_exited", queue_free)

func _on_visible():
    if !is_in_group("Grounded"):
        $AnimationPlayer.play("deploy")
        $Torch.play()
        var tween = create_tween()
        tween.tween_property($Torch, "volume_db", 0, 1)
    
func _process(_delta):
    if health <= 0:
        var g = global_transform.origin
        Globals.explode(Vector3(g.x - 5.0, g.y, g.z), 3, 8)
        Globals.score += PRICE

        if is_in_group("RewardHealth"):
            spawn_life("health")

        if is_in_group("RewardMissiles"):
            spawn_life("missiles")

        if is_in_group("RewardBlast"):
            spawn_life("blast")
            
        queue_free()

func spawn_life(life_type):
    if not life_spawned:
        var life = LIFE.instantiate()
        life.life_type = life_type
        get_parent().add_child(life)
        life.global_transform.origin = global_transform.origin
        life_spawned = true
        
func _on_area_3d_body_entered(body):
    if body.name == "ShipHitBox":
        Globals.health -= 25
