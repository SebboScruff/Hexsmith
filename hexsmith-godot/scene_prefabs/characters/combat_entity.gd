# General, all-encompassing combat manager, to be given to anything that can be
# attacked: the player, all enemies, some environmental objects and even some
# spell effects will have CombatEntities assigned to them.
# Manages things like HP values, death functions, weaknesses and resistances
# to different Mana Colours.
# Make sure this is always a direct child of any node it is on, and is never renamed,
# so that accessing it can be called easily through Node.get_child("CombatEntity")

class_name CombatEntity
extends Node

#region Debug Variables
# I set up a pretty robust debug window that can be toggled on or off 
# on a per-combat-entity basis. Shows a bunch of useful info for testing numbers.
@export var show_damage_debug:bool
@onready var debug_damage_readout: PanelContainer = %damage_readout
var debug_damage_total:float
# ---
@onready var debug_label_raw: Label = $damage_readout/VBoxContainer/last_damage_raw_amount
@onready var debug_label_actual: Label = $damage_readout/VBoxContainer/last_damage_real_amount
@onready var debug_label_type: Label = $damage_readout/VBoxContainer/last_damage_type
@onready var debug_label_total: Label = $damage_readout/VBoxContainer/total_damage
@onready var debug_reset_timer: Timer = $damage_readout/damage_readout_reset
#endregion

enum DAMAGE_TYPES{
	PHYSICAL,	# 0
	RED,		# 1 
	BLUE,		# 2
	GREEN,		# 3 
	WHITE,		# 4
	BLACK,		# 5
	HP_REMOVAL	# 6 (for things like Instakill traps, drowning damage, etc. Always keep at 1
}

## Damage Modification Multipliers as floats:
## 0 = Physical; 1 = Red; 2 = Blue; 3 = Green; 4 = White; 5 = Black; 6 = HP Removal (aka Pure Damage).
## If value is 0, this Entity is immune to that type of damage. 
## If value is 1, this Entity takes regular unmodified damage from that type.
## NOTE: The value for HP Removal (index 6) should always be at exactly 1.0
@export var incoming_damage_multipliers = {
	DAMAGE_TYPES.PHYSICAL : 1.0,
	DAMAGE_TYPES.RED : 1.0,
	DAMAGE_TYPES.BLUE : 1.0,
	DAMAGE_TYPES.GREEN : 1.0,
	DAMAGE_TYPES.WHITE : 1.0,
	DAMAGE_TYPES.BLACK : 1.0,
	DAMAGE_TYPES.HP_REMOVAL : 1.0
}

# General HP Stats. Most enemies will have 0 health regen.
@export var max_health : float
var curr_health : float
@export var health_regen_rate : float ## This entity's natural health gain in HP/s. Should be 0 for most standard enemies.

# NOTE: Only some CombatEntities (for example, the Player and major bosses)
# will have visual health bars. As a result, this needs a nullcheck before
# it is used in update_health_visual()
var health_bar_visual : TextureProgressBar

# Signals set up to proc animations, particle systems, and other damage/healing related effects
# in other scripts. Combat Entities are always standalone child nodes so accessing these in other
# scripts is pretty trivial.
signal damage_taken(raw_amount:float, amount:float, type:DAMAGE_TYPES)
signal healed
signal has_died

# Reset HP on ready.
# TODO: Eventually this will need to be extracted into save data instead, especially for the player.
func _ready() -> void:
	curr_health = max_health
	
	debug_damage_readout.set_visible(show_damage_debug)


# Simple addition with upper clamp.
func gain_health(_amount:float, is_standard_regen:bool = false):
	# Health gain with basic clamp
	if(curr_health + _amount > max_health):
		curr_health = max_health
	else:
		curr_health += _amount
	
	# Have the signal only emit for 'special' or 'burst' healing, e.g. from
	# potions or healing spells. That way, heal animations/particles won't proc from
	# the player's standard regen.
	if(!is_standard_regen):
		healed.emit() 
	
	update_health_visual()

# Modify incoming amount according to own damage modifiers
# then reduce HP accordingly
func take_damage(_amount:float, _type:DAMAGE_TYPES):
	var actual_amount = _amount
	actual_amount *= incoming_damage_multipliers[_type]
	
	curr_health -= actual_amount
	# Emit a signal for any uses elsewhere - animations, particle systems, 
	# enemy state changes, etc.
	damage_taken.emit(_amount, actual_amount, _type)
	update_health_visual()
	
	# Update the Debug Readout. Even in release, I think keeping this is a good
	# idea so that we can have the Target Dummy with exact damage values showing. 
	# That way, players can practice different combos/attacks/upgrades. Shoutout
	# to Target Dummy from Dota
	#region DEBUG ZONE
	debug_damage_total += actual_amount
	
	debug_label_raw.text = "Raw: %d"%[_amount]
	debug_label_actual.text = "Actual: %d"%[actual_amount]
	debug_label_type.text = "Type: %s"%[DAMAGE_TYPES.keys()[_type]]
	debug_label_total.text = "Total: %8.3f"%[debug_damage_total]
	
	debug_reset_timer.start()
	#endregion
	# Death check every time damage is taken.
	if(curr_health <= 0):
		die()

# Nullcheck then UI update,
# since not every entity will have a visual health bar
func update_health_visual() -> void:
	if(health_bar_visual != null):
		health_bar_visual.max_value = max_health
		health_bar_visual.value = curr_health

# Individual death behaviours will differ wildly depending on
# which entity died - from just dropping XP, to restarting the entire game.
# As such, this is a signal emission and nothing else.
func die() -> void:
	has_died.emit()

# Reset the Debug Readout window after a certain number of seconds.
func _on_damage_readout_reset_timeout() -> void:
	debug_damage_total = 0
	
	debug_label_raw.text = "[Raw Damage]"
	debug_label_actual.text = "[Damage Taken]"
	debug_label_type.text = "[Damage Type]"
	debug_label_total.text = "Total: %8.3f"%[debug_damage_total]
