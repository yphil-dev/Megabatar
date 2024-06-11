extends ProgressBar

@onready var damage_bar = $DamageBar

var max_health:int
var health:int
var health_inited = false
        
func _process(_delta):
    if Globals.boss_health > 0:
        visible = true
        if !health_inited:
            init_health(Globals.boss_health)
            health_inited = true
    else:
        visible = false
        if Globals.boss_health == 0:
            health_inited = false

    health = Globals.boss_health
    value = health
    
func init_health(_health):
    if health_inited:
        return
    health = _health
    value = health
    max_value = health
