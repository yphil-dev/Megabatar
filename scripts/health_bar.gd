extends ProgressBar

@onready var damage_bar = $DamageBar
@onready var hit_timer = $HitTimer

#@onready var style = theme.get_stylebox("fill", "ProgressBar")
#var colors: Array[Color] = [Color.RED, Color.GREEN]

const max_health = 100

var health = 100: set = _set_health

func _set_health(new_health):

    if health == new_health:
        return

    var previous_health = health
    health = min(max_value, new_health)
    value = health
    
    if health <= 0:
        queue_free()
        
    if health < previous_health:
        hit_timer.start()
    else:
        damage_bar.value = health

func _ready():
    pass
    # init_health(100)

func _process(_delta):
    health = Globals.health
    value = health
    
func init_health(_health):
    health = _health
    max_value = health
    value = health
    damage_bar.max_value = health
    damage_bar.value = health	

func _on_timer_timeout():
    damage_bar.value = health
