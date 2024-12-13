class_name SpellSuffix extends Node2D

enum CAST_TYPES{
	SINGLE_CAST, # One used, goes on cooldown
	TOGGLE,				# Has an on-off switch.
	PRESS_AND_HOLD		# Has to  be held down for continual effect.
}

enum TARGET_TYPES{
	RAW_DIRECTION,	# Player->Crosshair direction vector, include brief timeslow at start
	WALL_OR_FLOOR,	# Player->Crosshair raycast, collides with walls or floors, get surface normal
	SELF			# Affects only the Player
}

var suffix_name:String
var suffix_id:int ## NOTE: Very important for managing Cooldowns and Toggles

var cast_type: CAST_TYPES
# Whether or not a TOGGLE spell is currently turned on, 
# or a PRESS_AND_HOLD spell is currently held down.
var is_active: bool 
var target_type: TARGET_TYPES

## This will be per-cast (and generally higher) for CAST_WILL_COOLDOWN spells
## and per-second (while active) - and generally lower - for TOGGLED spells.
## Spell mana cost is calculated per-colour, and follows:
## colour_cost = [this] * num_color_instances
var base_mana_cost: float

const icon_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/icons/"
var spell_icon: CompressedTexture2D

var player : Player # This value is assigned in spell._init()

# NOTE: Cooldowns are shared between suffixes - putting 1 Bolt spell on cooldown
# will put all possible bolts on cooldown. This value is irrelevant for Toggles.
var cooldown_max: float

# Pass in stuff from Prefix, for use in things like particle/ projectile instantiation
# and Shader Initialisation.
var colors_from_prefix:Array[Color]

# TODO Pass in a "Damage Multiplier Matrix" from the Prefix. Each Prefix wants to have
# a different set of effectivenesses (e.g. Red resisted by Blue; Red-White strong against Blue)

func _init() -> void:
	pass

# Called on KeyDown, for doing any pre-cast behaviours
# for example, a slow-down feature to help with aiming,
# a preview of mana costs in the HUD, or a
# particle/animation on the player's sprite.
# For Toggles, this is not used.
func precast() -> void:
	match(cast_type):
		CAST_TYPES.SINGLE_CAST:
			print("%s is precasting a %s Spell"%[player.name, suffix_name])
			#TODO start the pre-cast particles.
		CAST_TYPES.TOGGLE:
			print("No default pre-cast behaviours for %s Spells."%[suffix_name])
		CAST_TYPES.PRESS_AND_HOLD:
			print("%s Spell turned on"%[suffix_name])
			set_active(true)

## This must be overridden in all SINGLE_CAST Suffixes
## Determines all cast behaviours: whether something needs to be instantiated, 
## activating or deactivating certain aspects of the player's prefab,
## moving the player in some way, or anything else.
## Prefix-specific aspects will also be defined here.
# Called on KeyUp, to initiate all post-cast behaviours of the spell.
@warning_ignore("unused_parameter")
func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int) -> void:
	print("Casted a %s Spell. No cast behaviour implemented in inherited class!"%[suffix_name])

## This must be overridden along with do_effect() into Toggled Suffixes.
## Use this instead of cast() so you dont have to pass a bunch of meaningless 
## Mana Data
## May be able to utilise this for some cool bosses as well (they could break a spell slot temporarily)
func set_active(new_state:bool):
	is_active = new_state

## This must be overridden in all Toggled suffixes.
## As long as isActive is true, this will take place.
## Requires a Delta-Time pass-in to deal with any over-time effects like Mana Costs.
@warning_ignore("unused_parameter")
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	print("A %s Spell is currently active. No effect implemented yet."%[suffix_name])

func get_prefix_colors(_colors:Array[Color]) -> void:
	colors_from_prefix = _colors
