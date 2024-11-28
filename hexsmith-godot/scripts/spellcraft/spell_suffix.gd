class_name SpellSuffix extends Node2D

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

var suffix_name:String
var suffix_id:int ## NOTE: Very important for spells with Cooldowns.

var cast_type: CAST_TYPES
var is_active: bool
var target_type: TARGET_TYPES

## This will be per-cast (and generally higher) for CAST_WILL_COOLDOWN spells
## and per-second (while active) - and generally lower - for PASSIVE or TOGGLED spells.
## Spell mana cost is calculated per-colour, and follows:
## colour_cost = [this] * num_color_instances
var base_mana_cost: float

const icon_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/icons/"
var spell_icon: CompressedTexture2D

var player : Player

# TODO These can probably eventually be replaced by Godot Timers tied to the player
# Remember, casting a spell puts the SUFFIX on cooldown, not that specific Spell
# i.e. casting any Bolt spell puts ALL POSSIBLE Bolt spells on cooldown.
# Set to 0 if Toggled or Passive.
# var cooldown_current: float
var cooldown_max: float

# Pass in stuff from Prefix, for use in things like particle/ projectile instantiation
# and Shader Initialisation.
var colors_from_prefix:Array[Color]

func _init() -> void:
	pass

# Called on KeyDown, for doing any pre-cast behaviours
# for example, a slow-down feature to help with aiming,
# a preview of mana costs in the HUD, or a
# particle/animation on the player's sprite.
# For Toggles or Passives, this is not used.
func precast() -> void:
	if(cast_type != CAST_TYPES.CAST_WITH_COOLDOWN):
		print("No default pre-cast behaviours for %s Spells."%[suffix_name])
		return
	# NOTE: If it gets here, it's a cast with cooldown
	print("%s is precasting a %s Spell"%[player.name, suffix_name])
	# TODO Start a little time-slow effect for JUICE
	# and make sure the Cursor/ Crosshair is visible

## This must be overridden in all non-Passive Suffixes
## Determines all cast behaviours: whether something needs to be instantiated, 
## activating or deactivating certain aspects of the player's prefab,
## moving the player in some way, or anything else.
## Prefix-specific aspects will also be defined here.
# Called on KeyUp, to initiate all post-cast behaviours of the spell.
func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	print("Casted a %s Spell. No cast behaviour implemented in inherited class!"%[suffix_name])

## This must be overridden along with do_effect() into Toggled Suffixes.
## Use this instead of cast() so you dont have to pass a bunch of meaningless 
## Mana Data
## May be able to utilise this for some cool bosses as well (they could break a spell slot temporarily)
func toggle():
	is_active = !is_active
	print("Toggled a %s Spell. New state is %s"%[suffix_name, is_active])

## This must be overridden in all Passive or Toggled suffixes.
## As long as isActive is true, this will take place.
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	print("A %s Spell is currently active. No effect implemented yet."%[suffix_name])

func get_prefix_colors(_colors:Array[Color]) -> void:
	colors_from_prefix = _colors
