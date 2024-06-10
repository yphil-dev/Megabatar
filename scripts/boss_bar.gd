extends ProgressBar

@onready var damage_bar = $DamageBar
@onready var hit_timer = $HitTimer

#@onready var style = theme.get_stylebox("fill", "ProgressBar")
#var colors: Array[Color] = [Color.RED, Color.GREEN]

var max_health:int

var health: int: set = _set_health

func _set_health(new_health):

    # Globals.say("Setting health from {name} to {health}".format({"name":health, "health":new_health}))

    if health == new_health:
        return

    var previous_health = health
    health = min(max_value, new_health)
    value = health
    
    # if health <= 0:
    #     queue_free()
        
    if health < previous_health:
        hit_timer.start()
    else:
        damage_bar.value = health

    health = new_health
        
# func _ready():
#     health = (Globals.level_num + 1) * 250
#     Globals.say("Init health to {health}".format({"health":health}))
#     # init_health((Globals.level_num + 1) * 250)
#     max_value = health
#     value = health

func _process(_delta):
    # Globals.say("Globals.boss_health {health}".format({"health":Globals.boss_health}))
    if Globals.boss_health > 0:
        visible = true
    else:
        visible = false

    health = Globals.boss_health
    value = health
        
func init_health():
    health = (Globals.level_num + 1) * 250
    max_value = health
    value = health

func _on_timer_timeout():
    damage_bar.value = health
