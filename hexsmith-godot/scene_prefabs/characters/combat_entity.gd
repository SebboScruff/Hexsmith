# General, all-encompassing combat manager, to be given to anything that can be
# attacked: the player, all enemies, some environmental objects and even some
# spell effects will have CombatEntities assigned to them.
# Manages things like HP values, death functions, weaknesses and resistances
# to different Mana Colours.
# Make sure this is always a direct child of any node it is on, and is never renamed,
# so that accessing it can be called easily through Node.get_child("CombatEntity")

class_name CombatEntity
extends Node

enum DAMAGE_TYPES{
	PHYSICAL,	# 0
	RED,		# 1 
	BLUE,		# 2
	GREEN,		# 3 
	WHITE,		# 4
	BLACK		# 5
}
# provided as a dictionary for easy lookup.
## Damage Modification Multipliers as floats:
## 0 = Physical; 1 = Red; 2 = Blue; 3 = Green; 4 = White; 5 = Black.
## If value is 0, this Entity is immune to that type of damage. 
## If value is 1, this Entity takes regular unmodified damage from that type.
@export var incoming_damage_multipliers = {
	DAMAGE_TYPES.PHYSICAL : 1.0,
	DAMAGE_TYPES.RED : 1.0,
	DAMAGE_TYPES.BLUE : 1.0,
	DAMAGE_TYPES.GREEN : 1.0,
	DAMAGE_TYPES.WHITE : 1.0,
	DAMAGE_TYPES.BLACK : 1.0,
}

@export var max_health : float
var curr_health : float
# Set this up as a signal to proc Hurt animations, reduce player's HUD healthbar, etc
signal damage_taken(amount:float, type:DAMAGE_TYPES)
signal has_died

# Simple addition with upper clamp.
func gain_health(_amount:float):
	curr_health += _amount
	if(curr_health > max_health):
		curr_health = max_health

# Modify incoming amount according to own damage modifiers
# then reduce HP accordingly
func take_damage(_amount:float, _type:DAMAGE_TYPES):
	damage_taken.emit(_amount, _type)
	var actual_amount = _amount
	if(incoming_damage_multipliers.has_key(_type)):
		actual_amount *= incoming_damage_multipliers[_type]
	
	curr_health -= actual_amount
	
	if(curr_health >= 0):
		die()
	
func die() -> void:
	# emit a signal, and do nothing else on the generic Combat Entity end.
	# This function will have wildly different effects based on whether it was
	# the player, an enemy, a boss, etc that died. Case-by-cases can be dealt with
	# in the corresponding entity's main behaviours.
	has_died.emit()
