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
@export var hud_manager : HudManager = player_hud as HudManager

const gui_instances_path: String = "spellcraft_hud/VBoxContainer/ManaInstancesBG/ActiveManaInstancesContainer"
var gui_instances_container: GridContainer

const class_selector_path: String = "spellcraft_hud/VBoxContainer/spellcraft_class_selector/SpellcraftClassSelector"
var class_selector: SpellClassSelector

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
	class_selector = player_hud.get_node(class_selector_path)

func initialise_prefix_dict():
	# bruh this is the exact opposite of risk-averse
	# TODO definitely try preloading this somehow once the game gets a bit more complex.
	prefix_dictionary = {
			#TODO As per BLAZING, change all Keys to raw arrays rather than new ACT instances
			# Mono-Colour Prefixes
			[true,false,false,false,false] : SpellPrefix.Blazing.new(spellcraft_amt.num_red, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,true,false,false,false) : SpellPrefix.Aqua.new(spellcraft_amt.num_blue, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,false,true,false,false) : SpellPrefix.Phyto.new(spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,false,false,true,false) : SpellPrefix.Lumina.new(spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,false,false,false,true) : SpellPrefix.Umbral.new(spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			# Two-Colour Prefixes
			ActiveColourTracker.new(true,true,false,false,false) : SpellPrefix.Steam.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,false,true,false,false) : SpellPrefix.Carbon.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,false,false,true,false) : SpellPrefix.Gigawatt.new(spellcraft_amt.num_red, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,false,false,false,true) : SpellPrefix.Infernal.new(spellcraft_amt.num_red, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(false,true,true,false,false) : SpellPrefix.Terra.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,true,false,true,false) : SpellPrefix.Boreal.new(spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,true,false,false,true) : SpellPrefix.Hadal.new(spellcraft_amt.num_blue, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(false,false,true,true,false) : SpellPrefix.Floral.new(spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,false,true,false,true) : SpellPrefix.Fungal.new(spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(false,false,false,true,true) : SpellPrefix.Twilight.new(spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			# Three-Colour Prefixes
			ActiveColourTracker.new(true,true,true,false,false) : SpellPrefix.Prismatic.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,true,false,true,false) : SpellPrefix.Tempest.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,true,false,false,true) : SpellPrefix.BlackOil.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(true,false,true,true,false) : SpellPrefix.Silica.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(true,false,true,false,true) : SpellPrefix.Ashen.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(true,false,false,true,true) : SpellPrefix.Thundercloud.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
		
			ActiveColourTracker.new(false,true,true,true,false) : SpellPrefix.Coral.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			ActiveColourTracker.new(false,true,true,false,true) : SpellPrefix.Mire.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			ActiveColourTracker.new(false,true,false,true,true) : SpellPrefix.Arctic.new(spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
		
			ActiveColourTracker.new(false,false,true,true,true) : SpellPrefix.Toxic.new(spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
		}

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
# This will likely require a full refactor of how Active Mana is managed, 
# placing the Active Mana Instances into an array so that there 
# is a de facto undo-stack using pop_back()
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
	if(crafted_spell_prefix == null || crafted_spell_suffix == null):
		print("Prefix or Suffix is Null. Check Debug Logs")
		return
	
	var crafted_spell:Spell = Spell.new(crafted_spell_prefix, crafted_spell_suffix)
	
	# then assign that new Spell to the associated spell slot passed in as parameter
	print("TODO Craft and Bind to Spell Slot " + var_to_str(spell_slot_index))
	
	# and finally, clear and close the Spellcraft Menu
	clear_active_mana()
	gsm.change_game_state(States.GAME_STATES.OVERWORLD)
	hud_manager.change_active_menu(0)

func determine_prefix() -> SpellPrefix:
	var prefix : SpellPrefix = null
	
	# The problem here is that ActiveColourTrackers (being a Resource derivative)
	# are passed by reference rather than value - the Dict keys are raw Arrays,
	# and we need the custom pass-by-value getter to pass the player's Colour Tracker
	# as a valid Dictionary Key.
	prefix = prefix_dictionary[spellcraft_act.get_by_value()]
	
	if(prefix == null):
		print("No Prefix found in Dictionary for that Colour Combo! Double Check in spellcraft_manager.gd.")
		return
	
	print("Prefix Found: " + prefix.prefix_name)
	return prefix

func determine_suffix() -> SpellSuffix:
	var suffix : SpellSuffix = null
	
	## TODO Selection Algorithm Here:
	## This will definitely need refactoring and optimising
	match(class_selector.current_class):
		SpellClassSelector.SPELL_CLASSES.TELUMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = Bolt.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					suffix = Spike.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				3:
					suffix = Beam.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				4:
					suffix = Spear.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				5:
					suffix = Eruption.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
		SpellClassSelector.SPELL_CLASSES.MOTOMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = Strider.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					suffix = Transmission.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				3:
					suffix = Leap.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				4:
					suffix = Flight.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				5:
					suffix = Blink.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
		SpellClassSelector.SPELL_CLASSES.INSTRUMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = Transmutation.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					suffix = Cloak.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				3:
					suffix = Barrier.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				4:
					suffix = Blade.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
				5:
					suffix = SummonFamiliar.new()
					print("Suffix Found: " + suffix.suffix_name)
					return suffix
	
	if(suffix == null):
		print("No Suffix found that Class/Mana Combo! Double Check in spellcraft_manager.gd.")
		return
	
	return suffix
