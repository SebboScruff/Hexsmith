## Storage script for every type of Spell Prefix, and their
## associated Mana Colour Combinations.

## All prefixes have support for their input colours as well as colourless mana,
## and these specific numerical values are used in calculating both the Spell's
## specific stats as well as in-game mana cost to cast.

class_name SpellPrefix 
var prefix_name:String
var prefix_id: int
# TODO Prefixes are used in part to determine spell aesthetics:
# Eventually this generic class (and all the specific subclasses below)
# will want a handful of colours (2-5) and a small sound library associated
# with them for use in Shaders and Cast functions.
# TODO Each Prefix will also need an Icon Frame assigned. This is a 
# transparent square with an animated decal around it, to frame the suffix's
# spell icon
var spell_icon_frame : TextureRect

var num_red_mana : int
var num_blue_mana : int
var num_green_mana : int
var num_black_mana : int
var num_white_mana : int
var num_colorless_mana : int

##############################################
## INDIVIDUAL PREFIX DECLARATIONS BELOW     ##
## These are effectively constructor-only   ##
## classes for storing coloured mana values ##
## created when Spellcrafting               ##
## ---------------------------------------- ##
## TODO: This entire section could probably ##
## be refactored as a JSON read-in or       ##
## something at a future point              ##
##############################################

## 1-MANA PREFIXES:
class Blazing extends SpellPrefix: # 0: Mono-Red
	func _init(input_red:int, input_colourless:int):
		prefix_name = "Blazing"
		prefix_id = 0
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Aqua extends SpellPrefix: # 1: Mono-Blue
	func _init(input_blue:int, input_colourless:int):
		prefix_name = "Aqua"
		prefix_id = 1
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Phyto extends SpellPrefix: # 2: Mono-Green
	func _init(input_green:int, input_colourless:int):
		prefix_name = "Phyto"
		prefix_id = 2
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Lumina extends SpellPrefix: # 3: Mono-White
	func _init(input_white:int, input_colourless:int):
		prefix_name = "Lumina"
		prefix_id = 3
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Umbral extends SpellPrefix: # 4: Mono-Black
	func _init(input_black:int, input_colourless:int):
		prefix_name = "Umbral"
		prefix_id = 4
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless
## END OF 1-MANA PREFIXES

## 2-MANA PREFIXES
class Steam extends SpellPrefix: # 5: Red-Blue
	func _init(input_red:int, input_blue:int, input_colourless:int):
		prefix_name = "Steam"
		prefix_id = 5
		
		num_red_mana = input_red
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Carbon extends SpellPrefix: # 6: Red-Green
	func _init(input_red:int, input_green:int, input_colourless:int):
		prefix_name = "Carbon"
		prefix_id = 6
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Gigawatt extends SpellPrefix: # 7: Red-White
	func _init(input_red:int, input_white:int, input_colourless:int):
		prefix_name = "Gigawatt"
		prefix_id = 7
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Infernal extends SpellPrefix: # 8: Red-Black
	func _init(input_red:int, input_black:int, input_colourless:int):
		prefix_name = "Infernal"
		prefix_id = 8
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Terra extends SpellPrefix: # 9: Blue-Green
	func _init(input_blue:int, input_green:int, input_colourless:int):
		prefix_name = "Terra"
		prefix_id = 9
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Boreal extends SpellPrefix: # 10: Blue-White
	func _init(input_blue:int, input_white:int, input_colourless:int):
		prefix_name = "Boreal"
		prefix_id = 10
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Hadal extends SpellPrefix: # 11: Blue-Black
	func _init(input_blue:int, input_black:int, input_colourless:int):
		prefix_name = "Hadal"
		prefix_id = 11
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Floral extends SpellPrefix: # 12: Green-White
	func _init(input_green:int, input_white:int, input_colourless:int):
		prefix_name = "Floral"
		prefix_id = 12
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Fungal extends SpellPrefix: # 13: Green-Black
	func _init(input_green:int, input_black:int, input_colourless:int):
		prefix_name = "Fungal"
		prefix_id = 13
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Twilight extends SpellPrefix: # 14: White-Black
	func _init(input_white:int, input_black:int, input_colourless:int):
		prefix_name = "Twilight"
		prefix_id = 14
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = input_black
		num_colorless_mana = input_colourless
## END OF 2-MANA PREFIXES

## 3-MANA PREFIXES
class Prismatic extends SpellPrefix: # 15: Red-Blue-Green
	func _init(input_red:int, input_blue:int, input_green:int, input_colourless:int):
		prefix_name = "Prismatic"
		prefix_id = 15
		
		num_red_mana = input_red
		num_blue_mana = input_blue
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Tempest extends SpellPrefix: # 16: Red-Blue-White
	func _init(input_red:int, input_blue:int, input_white:int, input_colourless:int):
		prefix_name = "Tempest"
		prefix_id = 16
		
		num_red_mana = input_red
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class BlackOil extends SpellPrefix: # 17: Red-Blue-Black
	func _init(input_red:int, input_blue:int, input_black:int, input_colourless:int):
		prefix_name = "Black Oil"
		prefix_id = 17
		
		num_red_mana = input_red
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Silica extends SpellPrefix: # 18: Red-Green-White
	func _init(input_red:int, input_green:int, input_white:int, input_colourless:int):
		prefix_name = "Silica"
		prefix_id = 18
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Ashen extends SpellPrefix: # 19: Red-Green-Black
	func _init(input_red:int, input_green:int, input_black:int, input_colourless:int):
		prefix_name = "Ashen"
		prefix_id = 19
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Thundercloud extends SpellPrefix: # 20: Red-White-Black
	func _init(input_red:int, input_white:int, input_black:int, input_colourless:int):
		prefix_name = "Thundercloud"
		prefix_id = 20
		
		num_red_mana = input_red
		num_blue_mana = 0
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Coral extends SpellPrefix: # 21: Blue-Green-White
	func _init(input_blue:int, input_green:int, input_white:int, input_colourless:int):
		prefix_name = "Coral"
		prefix_id = 21
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = input_green
		num_white_mana = input_white
		num_black_mana = 0
		num_colorless_mana = input_colourless

class Mire extends SpellPrefix: # 22: Blue-Green-Black
	func _init(input_blue:int, input_green:int, input_black:int, input_colourless:int):
		prefix_name = "Mire"
		prefix_id = 22
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = input_green
		num_white_mana = 0
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Arctic extends SpellPrefix: # 23: Blue-White-Black
	func _init(input_blue:int, input_white:int, input_black:int, input_colourless:int):
		prefix_name = "Arctic"
		prefix_id = 23
		
		num_red_mana = 0
		num_blue_mana = input_blue
		num_green_mana = 0
		num_white_mana = input_white
		num_black_mana = input_black
		num_colorless_mana = input_colourless

class Toxic extends SpellPrefix: # 24: Green-White-Black
	func _init(input_green:int, input_white:int, input_black:int, input_colourless:int):
		prefix_name = "Toxic"
		prefix_id = 24
		
		num_red_mana = 0
		num_blue_mana = 0
		num_green_mana = input_green
		num_white_mana = input_white
		num_black_mana = input_black
		num_colorless_mana = input_colourless
## END OF 3-MANA PREFIXES
