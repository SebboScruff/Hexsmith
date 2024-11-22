# Effectively just a strucet of 6 ints, used by the Spellcraft Manager
# to keep track of the player's currently added mana

class_name ActiveManaTracker
extends Resource

@export var num_red: int
@export var num_blue: int
@export var num_green: int
@export var num_white: int
@export var num_black: int
@export var num_colourless: int

@export var total_current_mana: int

func _init(_red:int, _blue:int, _green:int, _white:int, _black:int, _colourless:int) -> void:
	num_red = _red
	num_blue = _blue
	num_green = _green
	num_white = _white
	num_black = _black
	num_colourless = _colourless

func reset() -> void:
	num_red = 0
	num_blue = 0
	num_green = 0
	num_white = 0
	num_black = 0
	num_colourless = 0
	
	total_current_mana = 0

func debug_readout() -> void:
	var format_string = "Current Active Mana Count: %d Red/ %d Blue/ %d Green/ %d White/ %d Black/ %d Colourless. %d Mana Total"
	var print_message = format_string % [num_red, num_blue, num_green, num_white, num_black, num_colourless, total_current_mana]
	print(print_message)
