# Effectively just a strucet of 5 bools, used by the Spellcraft Manager
# to keep track of the player's currently added mana colours.

class_name ActiveColourTracker
extends Resource

@export var has_red:bool
@export var has_blue:bool
@export var has_green:bool
@export var has_white:bool
@export var has_black:bool

@export var total_active_colours: int

func _init(_red:bool, _blue:bool, _green:bool, _white:bool, _black:bool) -> void:
	has_red = _red
	has_blue = _blue
	has_green = _green
	has_white = _white
	has_black = _black

func reset() -> void:
	has_red = false
	has_blue = false
	has_green = false
	has_white = false
	has_black = false
	
	total_active_colours = 0

# TODO should probably add a debug readout here similar to ActiveManaTracker
