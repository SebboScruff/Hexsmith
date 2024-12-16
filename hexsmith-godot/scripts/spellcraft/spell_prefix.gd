## Storage script for every type of Spell Prefix, and their
## associated Mana Colour Combinations.

## All prefixes have support for their input colours as well as colourless mana,
## and these specific numerical values are used in calculating both the Spell's
## specific stats as well as in-game mana cost to cast.

class_name SpellPrefix

# Identification Parameters
var prefix_name:String
var prefix_id: int

# VFX and SFX Parameters
# TODO Optimisation: This could probably be compressed to an Atlas Texture
# eventually, rather than 25 (animated) image sets
const icon_frame_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/frames/"
var spell_icon_frame : CompressedTexture2D
# var precast_particles : GPUParticles2D # TODO Fill in every prefix with a precast particle

var colors : Array[Color]
# TODO var sound_effect_source

# Specific Mana Quantities
var num_red_mana : int
var num_blue_mana : int
var num_green_mana : int
var num_black_mana : int
var num_white_mana : int
var num_colorless_mana : int

#########################################################
## INDIVIDUAL PREFIX DECLARATIONS                      ##
## Can be found in scripts/spellcraft/spell_prefixes/  ##
## May be able to refactor and clean up a little bit   ##
#########################################################

# Universal getter for Mana Values as a compact float.
# Values are in order Red (index 0), Blue, Green, White, Black, Colorless (index 5)
func get_mana_values() -> Array[float]:
	var mana_values = [num_red_mana,num_blue_mana,num_green_mana,
	num_white_mana,num_black_mana,num_colorless_mana]
	return mana_values
