class_name SpellSuffix

enum CAST_TYPES{
	CAST_WITH_COOLDOWN, # One used, goes on cooldown
	PASSIVE,			# Always active, not necessarily always draining mana
	TOGGLE				# Has an on-off switch.
}

enum TARGET_TYPES{
	RAW_DIRECTION,	# Player->Crosshair direction vector, include brief timeslow at start
	WALL_OR_FLOOR,	# Player->Crosshair raycast, collides with walls or floors, get surface normal
	SELF			# Affects only the Player
}

var suffix_name: String

var cast_type: CAST_TYPES
var is_active: bool
var target_type: TARGET_TYPES

const icon_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/icons/"
var spell_icon: CompressedTexture2D

# TODO These can probably eventually be replaced by Godot Timers tied to the player
# Remember, casting a spell puts the SUFFIX on cooldown, not that specific Spell
# i.e. casting any Bolt spell puts ALL POSSIBLE Bolt spells on cooldown.
# Set to 0 if Toggled or Passive.
var cooldown_current: float
var cooldown_max: float

func _init() -> void:
	pass

# Called on KeyDown, for doing any pre-cast behaviours
# for example, a slow-down feature to help with aiming,
# a preview of mana costs in the HUD, or a
# particle/animation on the player's sprite.
# For Toggles or Passives, this is not used.
func precast() -> void:
	print("No default pre-cast behaviours for this spell.")
	pass

## This must be overridden in all non-Passive Suffixes
## Determines all cast behaviours: whether something needs to be instantiated, 
## activating or deactivating certain aspects of the player's prefab,
## moving the player in some way, or anything else.
## Prefix-specific aspects will also be defined here.
# Called on KeyUp, to initiate all post-cast behaviours of the spell.
func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	pass

## This must be overridden along with do_effect() into Toggled Suffixes.
## Use this instead of cast() so you dont have to pass a bunch of meaningless 
## Mana Data
## May be able to utilise this for some cool bosses as well (they could break a spell slot temporarily)
func toggle():
	pass

## This must be overridden in all Passive or Toggled suffixes.
## As long as isActive is true, this will take place.
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	pass
