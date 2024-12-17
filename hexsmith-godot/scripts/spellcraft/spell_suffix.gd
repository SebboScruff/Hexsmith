## Abstract class for organising all spell suffix behaviours. Inherit into specific suffix
## classes, and override functions where appropriate. Details and docs are in Obsidian vault.

class_name SpellSuffix extends Node2D

enum CAST_TYPES{
	SINGLE_CAST, 		# Once used, does a single effect and goes on cooldown.
	TOGGLE,				# Has an on-off switch, changed on Key Up.
	CHANNEL				# Has to  be held down for continual effect.
}
var suffix_name:String
var suffix_id:int ## NOTE: Very important for managing Cooldowns and Toggles

var cast_type: CAST_TYPES

# Whether or not a TOGGLE spell is currently turned on, 
# or a CHANNEL spell is currently held down.
var active_state: bool 

## This will be per-cast (and generally higher) for CAST_WILL_COOLDOWN spells
## and per-second (while active) - and generally lower - for TOGGLED spells.
## Spell mana cost is calculated per-colour, and follows:
## colour_cost = [this] * num_color_instances
var base_mana_cost: float
var is_mana_cost_active := true

const icon_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/icons/"
var spell_icon: CompressedTexture2D

# Reference to the player so spells can affect the correct entity, or spawn
# in the right place, etc.
var player : Player ## NOTE: This value is assigned in spell._init()

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

#region OVERRIDE IN SINGLE CAST
func on_precast() -> void:
	pass

func on_cast(_mana_inputs:Array[float]) -> void:
	pass
#endregion

## NOTE: Do not inherit this into any subclasses, since it is a bool switch that
## will behave identically between all spell suffixes. The basic implementation here will
## allow any spell to be turned on and off.
func set_active_state(_new_state:bool, _mana_values:Array[float]):
	if(_new_state == true):
		on_activate(_mana_values)
	else: # i.e. _new_state == false
		on_deactivate(_mana_values)

#region OVERRIDE IN TOGGLE/ CHANNEL

## Any special effects that happen when the spell is activated go here. For example,
## many Strider spells directly affect the player body in a number of ways when activated.
func on_activate(_mana_inputs:Array[float]) -> void:
	active_state = true

## For removing any special effects that happened in on_toggle_on()
func on_deactivate(_mana_inputs:Array[float]) -> void:
	active_state = false

func on_passive_effect(_delta:float, _mana_inputs:Array[float]):
	pass
#endregion
