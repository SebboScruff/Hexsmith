# A specialised subclass of Timer that carries an internal ID,
# to manage the Spell Cooldown System.
# Casting a Spell puts ALL Spells with that suffix on cooldown
class_name SpellCooldownTimer extends Timer

const SPELL_COOLDOWN_TIMER:PackedScene = preload("res://scene_prefabs/spell_cooldown_timer.tscn")
var timer_id:int

# Assign ID and Duration as part of the constructor, so Timers with different values can be
# easily instantiated.
static func create_new_cooldown_timer(_id:int, _duration:float) -> SpellCooldownTimer:
	var new_timer:SpellCooldownTimer = SPELL_COOLDOWN_TIMER.instantiate()
	
	new_timer.timer_id = _id
	new_timer.wait_time = _duration
	new_timer.autostart = true
	
	return new_timer


func _ready() -> void:
	start()

# I have no clue why hooking the timeout() signal doesnt work
# so our shitty bandaid replacement is a condition check every frame.
func _process(_delta: float) -> void:
	if(self.time_left <= 0):
		queue_free()
