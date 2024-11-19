# The central hub for everything spellcraft-related:
# Fundamental mechanics:
# - Adding and Removing Mana from current selection.
# - Reading current School Selection
# - Crafting and assigning to a hotkey
# Which Manas can the player use? How many total manas can they use? TODO
# Which spells do they currently have assigned to which hotkeys? TODO
# Which prefixes and suffixes has the player already learned? TODO
class_name SpellcraftManager
extends Node

## HELPER DATA STRUCTURES

# Effectively just a struct of 6 ints, used for determining Suffixes
class ActiveManaTracker:
	var num_red: int
	var num_blue: int
	var num_green: int
	var num_white: int
	var num_black: int
	var num_colourless: int
	
	var total_current_mana: int
	
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
	
	func debug_readout():
		var format_string = "Current Active Mana Count: %d Red/ %d Blue/ %d Green/ %d White/ %d Black/ %d Colourless. %d Mana Total"
		var print_message = format_string % [num_red, num_blue, num_green, num_white, num_black, num_colourless, total_current_mana]
		print(print_message)

# Similarly, this is a struct of 5 bools, used for determining Prefixes
class ActiveColourTracker:
	var has_red:bool
	var has_blue:bool
	var has_green:bool
	var has_white:bool
	var has_black:bool
	
	var total_active_colours: int
	
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

# This guy is gonna hold all 25 colour available colour combinations
# Uses ActiveColourTrackers as keys, and SpellPrefixes as values.
var prefix_dictionary = {}

enum MANA_COLOURS{
	RED,		# 0
	BLUE,		# 1
	GREEN,		# 2
	WHITE,		# 3
	BLACK,		# 4
	COLOURLESS	# 5
}
## END OF HELPER DATA STRUCTURES
# ------------------------------------
## VARIABLE DECLARATIONS ##
var spellcraft_amt : ActiveManaTracker
var spellcraft_act : ActiveColourTracker

const MAX_COLOURS : int = 3 # the maximum number of different colours that can be used in Spellcrafting
const MAX_MANA : int = 5 # the maximum number of total mana that can be used in spellcrafting

# HUD Elements
@onready var player_hud: HudManager = %PlayerHUD
# Need a reference to PlayerHUD/spellcraft_hud/VBoxContainer/ManaInstancesBG/ActiveManaInstancesContainer
const gui_instances_path: String = "spellcraft_hud/VBoxContainer/ManaInstancesBG/ActiveManaInstancesContainer"
var gui_instances_container: GridContainer

const BLACK_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/black_mana_icon.tscn")
const BLUE_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/blue_mana_icon.tscn")
const COLOURLESS_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/colourless_mana_icon.tscn")
const GREEN_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/green_mana_icon.tscn")
const RED_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/red_mana_icon.tscn")
const WHITE_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/white_mana_icon.tscn")

## END OF VARIABLE DECLARATIONS ##

func _ready() -> void:
	# Initialise the Colour Tracker to all false
	# And the Mana Tracker to All Zeroes
	spellcraft_act = ActiveColourTracker.new(false, false, false, false, false)
	spellcraft_amt = ActiveManaTracker.new(0,0,0,0,0,0)
	
	initialise_prefix_dict()
	
	gui_instances_container = player_hud.get_node(gui_instances_path)

func initialise_prefix_dict():
	# TODO This is basically gonna be a whole bunch of dictionary assignment calls
	# to put a new Prefix Instance to each ActiveColourTracker instance
	pass

func add_active_mana_instance(colour:MANA_COLOURS):
	# main function body in each colour case is very similar and 
	# that means this can almost certainly be improved or refactored
	# as such, comments are provided for Red case and no others
	# TODO think about refactoring this to make it more readable. Efficiency tests required.
	match colour:
		MANA_COLOURS.RED:
			if(spellcraft_act.total_active_colours == MAX_COLOURS && spellcraft_act.has_red == false):
				print("Colour limit reached. Cannot add Red Mana.")
				return
			
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return
			
			# At this point we are clear to start adding mana:
			# First, check if there is already a Red Instance
			# so we can update the Colour Tracker
			if(spellcraft_act.has_red == false):
				spellcraft_act.total_active_colours += 1
				spellcraft_act.has_red = true
			# Then, add the active mana instance
			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_red += 1
			# Finally, update the HUD
			gui_instances_container.add_child(RED_MANA_ICON.instantiate())
		MANA_COLOURS.BLUE:
			if(spellcraft_act.total_active_colours == MAX_COLOURS && spellcraft_act.has_blue == false):
				print("Colour limit reached. Cannot add Blue Mana.")
				return
		
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return

			if(spellcraft_act.has_blue == false):
				spellcraft_act.total_active_colours += 1
				spellcraft_act.has_blue = true

			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_blue += 1

			gui_instances_container.add_child(BLUE_MANA_ICON.instantiate())
		MANA_COLOURS.GREEN:
			if(spellcraft_act.total_active_colours == MAX_COLOURS && spellcraft_act.has_green == false):
				print("Colour limit reached. Cannot add Green Mana.")
				return
			
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return

			if(spellcraft_act.has_green == false):
				spellcraft_act.total_active_colours += 1
				spellcraft_act.has_green = true

			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_green += 1

			gui_instances_container.add_child(GREEN_MANA_ICON.instantiate())
		MANA_COLOURS.WHITE:
			if(spellcraft_act.total_active_colours == MAX_COLOURS && spellcraft_act.has_white == false):
				print("Colour limit reached. Cannot add White Mana.")
				return
			
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return

			if(spellcraft_act.has_white == false):
				spellcraft_act.total_active_colours += 1
				spellcraft_act.has_white = true

			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_white += 1

			gui_instances_container.add_child(WHITE_MANA_ICON.instantiate())
		MANA_COLOURS.BLACK:
			if(spellcraft_act.total_active_colours == MAX_COLOURS && spellcraft_act.has_black == false):
				print("Colour limit reached. Cannot add black Mana.")
				return
			
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return

			if(spellcraft_act.has_black == false):
				spellcraft_act.total_active_colours += 1
				spellcraft_act.has_black = true

			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_black += 1

			gui_instances_container.add_child(BLACK_MANA_ICON.instantiate())
		MANA_COLOURS.COLOURLESS:
			# Colourless is a unique case:
			# it does not count as a Coloured Mana for the Colour Tracker because
			# it has no prefixes assigned to it.
			if(spellcraft_amt.total_current_mana == MAX_MANA):
				print("Mana limit reached. Cannot add more Mana.")
				return
			
			spellcraft_amt.total_current_mana += 1
			spellcraft_amt.num_colourless += 1

			gui_instances_container.add_child(COLOURLESS_MANA_ICON.instantiate())
	
	# DEBUG ONLY: print out the current mana combination after every addition
	spellcraft_amt.debug_readout()

# TODO Remove the most recently added mana instance
# This will likely require a full refactor, placing the Active Mana Instances
# into an array so that there is a de facto undo-stack using pop_back()
func remove_last_instance():
	print("TODO Remove Last Mana Instance")

func clear_active_mana():
	# TODO Eventually refactor this, it's got a lot of arbitrary moving parts
	spellcraft_act.reset()
	spellcraft_amt.reset()
	
	# function body in /scripts/utils.gd
	# basically clear the active instances from the HUD
	var gui_instances = Utilities.get_child_nodes(gui_instances_container)
	for n in gui_instances:
		n.queue_free()
		

func craft_and_bind(spell_slot_index: int):
	# TODO Combine all spell inputs to create a new spell:
	# Preliminary checks:
	# # If number of manas == 0 OR number of Colours == 0 OR Selected Class is NONE.
	# # Do Nothing
	if(spellcraft_act.total_active_colours == 0 
	|| spellcraft_amt.total_current_mana == 0):
		return
	
	# Otherwise, create new SpellSuffix instance and SpellPrefix Instance
	var crafted_spell_prefix:SpellPrefix = determine_prefix()
	var crafted_spell_suffix:SpellSuffix = determine_suffix()
	# and assign to new Spell Instance
	var crafted_spell:Spell = Spell.new(crafted_spell_prefix, crafted_spell_suffix)
	# then assign that new Spell to the associated spell slot passed in as parameter
	print("TODO Craft and Bind to Spell Slot " + var_to_str(spell_slot_index))
	

func determine_prefix() -> SpellPrefix:
	var prefix : SpellPrefix = null
	
	# TODO Lookup in prefix_dictionary to assign value
	
	if(prefix == null):
		#print("No Prefix found in Dictionary for that Colour Combo! Double Check in spellcraft_manager.gd.")
		return
	print("Determine Prefix Function not implemented") # TODO Remove this
	return prefix
	
func determine_suffix() -> SpellSuffix:
	var suffix : SpellSuffix = null
	
	## TODO Selection Algorithm Here:
	# Check every combo of Class + number of active Mana to return new Suffix
	if(suffix == null):
		#print("No Suffix found that Class/Mana Combo! Double Check in spellcraft_manager.gd.")
		return
		
	print("Determine Suffix Function not implemented") # TODO Remove this
	return suffix
