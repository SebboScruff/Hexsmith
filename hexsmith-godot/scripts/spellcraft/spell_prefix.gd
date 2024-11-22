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
const icon_frame_root_path = "res://assets/sprites/menus_and_gui/overworld_hud_imgs/spell_slots/frames/"
var spell_icon_frame : CompressedTexture2D

var colors : Array[Color]
# TODO var sound_effect_source

# Mana Values
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
