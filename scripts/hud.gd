extends Control

# Initialize previous states
var previous_has_blast = false
var previous_has_missiles = false

func _ready():
    # Initialize previous states in _ready to ensure they have initial values
    previous_has_blast = Globals.has_blast
    previous_has_missiles = Globals.has_missiles

func _process(_delta):
    # Update the UI elements
    $ScoreLabel.text = str(Globals.score)
    $WeaponsControls/Lasers/LaserChargeBar.value = Globals.laser_charge
    $WeaponsControls/Lasers/LaserChargeBar.get_theme_stylebox("fill").bg_color = Color.GREEN if Globals.laser_charge > 90 else Color.RED
    
    if Globals.has_missiles:
        $WeaponsControls/Missiles.visible = true
        $WeaponsControls/Missiles/RChargeBar.get_theme_stylebox("fill").bg_color = Color.GREEN if Globals.r_rocket_charge > 90 else Color.RED
        $WeaponsControls/Missiles/LChargeBar.get_theme_stylebox("fill").bg_color = Color.GREEN if Globals.l_rocket_charge > 90 else Color.RED
        $WeaponsControls/Missiles/RChargeBar.value = Globals.r_rocket_charge
        $WeaponsControls/Missiles/LChargeBar.value = Globals.l_rocket_charge
    
    $WeaponsControls/Blast.visible = Globals.has_blast
    
    weapons_check()

func weapons_check():
    if Globals.has_blast and not previous_has_blast:
        on_blast_activated()
    
    if Globals.has_missiles and not previous_has_missiles:
        on_missiles_activated()
    
    previous_has_blast = Globals.has_blast
    previous_has_missiles = Globals.has_missiles

@onready var BlastWave = $BlastWave
@onready var Missiles = $Missiles

func on_blast_activated():
    print("Blast activated")
    Globals.say("Blast activated")
    flash_weapons(BlastWave)
    
func on_missiles_activated():
    print("Missiles activated")
    Globals.say("Missiles activated")
    flash_weapons(Missiles)
    
func flash_weapons(weapon):
    $NewWeapon.play()
    $NewWeapon.finished.connect(weapon.play)
    var tween = get_tree().create_tween()
    tween.tween_property($WeaponsControls, "modulate:a", 0.1, 0.1)
    tween.tween_property($WeaponsControls, "modulate:a", 1.0, 0.1)
    tween.tween_property($WeaponsControls, "modulate:a", 0.1, 0.1)
    tween.tween_property($WeaponsControls, "modulate:a", 1.0, 0.1)
    tween.tween_property($WeaponsControls, "modulate:a", 0.1, 0.1)
    tween.tween_property($WeaponsControls, "modulate:a", 1.0, 0.1)
    # $NewWeapon.finished.disconnect(weapon.play)
