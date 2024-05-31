extends Node3D

@onready var Starship = preload("res://scenes/starship.tscn")
@onready var lives_container = $LivesContainer

var previous_lives = 0
var previous_health = 0

func _ready():
    init_nodes(Globals.lives)
    previous_lives = Globals.lives
    previous_health = Globals.health

func init_nodes(count):
    for i in range(count):
        await get_tree().create_timer(0.5).timeout
        add_life("init")

func hello():
    print("oh hi!")

func glow_last_life():
    var last_node = lives_container.get_child(lives_container.get_child_count() - 1)
    var mesh = last_node.get_child(0)
    var mat = mesh.get_surface_override_material(0)
    mesh.set_surface_override_material(0, mat.duplicate())
    var new_mat = mesh.get_surface_override_material(0)
    new_mat.emission_enabled = true
    var tween = create_tween()
    tween.tween_property(new_mat, "emission_energy_multiplier", 5.0, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(new_mat, "emission_energy_multiplier", 0, 0.2)
    mat.emission_enabled = false
    
func add_life(type):
    var new_life = Starship.instantiate()
    lives_container.add_child(new_life)

    # new_life.get_node("LifeLight").visible = true
    
    var marker_position = $LivesContainer/Marker3D.global_transform.origin
    var new_position = Vector3(marker_position.x - (0.08 * marker_position.x * lives_container.get_child_count()), marker_position.y, marker_position.z - 5.0)
    
    new_life.global_transform.origin = new_position
    new_life.scale = Vector3(0.8, 0.8, 0.8)
    var rotation_player = new_life.get_node("Rotate")
    rotation_player.play("r")
    $PlaneBell.play()
    if type == "new":
        $NewShip.play()

func sub_life():
    if lives_container.get_child_count() > 0:
        var last_node = lives_container.get_child(lives_container.get_child_count() - 1)
        last_node.get_node("Rotate").play("r")
        Globals.explode(Vector3(last_node.global_transform.origin), 2, 2)
        $RemLifeSound.play()
        await get_tree().create_timer(0.2).timeout
        lives_container.remove_child(last_node)

func _process(_delta):
    if previous_lives < Globals.lives:
        add_life("new")
    elif previous_lives > Globals.lives:
        sub_life()
    previous_lives = Globals.lives

    if previous_health < Globals.health:
        $Heal.play()
    previous_health = Globals.health
