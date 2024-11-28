# The central hub for everything spellcraft-related:
# Fundamental mechanics:
# - Adding and Removing Mana from current selection.
# - Reading current School Selection
# - Crafting and assigning to a hotkey
# Which Manas can the player use? How many total manas can they use? TODO
# Which prefixes and suffixes has the player already learned? TODO
class_name SpellcraftManager
extends Node

#region HELPER DATA STRUCTURES
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
#endregion
# ------------------------------------
#region VARIABLE DECLARATIONS
# Direct reference to the player, so it can be passed into crafted spells.
@onready var player: Player = $".."

# Data Structure instances for keeping track of 
# A) Total Mana Used, and B) Current Active Colours
var spellcraft_amt : ActiveManaTracker
var spellcraft_act : ActiveColourTracker

# These are eventually going to be tied to player progression and save states.
const MAX_COLOURS : int = 3 # the maximum number of different colours that can be used in Spellcrafting
const MAX_MANA : int = 5 # the maximum number of total mana that can be used in spellcrafting
#endregion

#region HUD Elements
# As with base player class, get a reference to the HUD object and controller script
# for visual HUD updates
@onready var player_hud: HudManager = %PlayerHUD
@export var hud_manager : HudManager = player_hud as HudManager

# NOTE: This is the path that Active Mana Instances are put into on the HUD
const gui_instances_path: String = "spellcraft_hud/VBoxContainer/ManaInstancesBG/ActiveManaInstancesContainer"
var gui_instances_container: GridContainer

# NOTE: This is the cursor used to select classes.
# Behaviours defined in scene_prefabs/menus_and_guis/spellcraft_class_selector.gd
const class_selector_path: String = "spellcraft_hud/VBoxContainer/spellcraft_class_selector/SpellcraftClassSelector"
var class_selector: SpellClassSelector

# Each of the Mana Icons used in the HUD. These will eventually be animated.
const BLACK_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/black_mana_icon.tscn")
const BLUE_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/blue_mana_icon.tscn")
const COLOURLESS_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/colourless_mana_icon.tscn")
const GREEN_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/green_mana_icon.tscn")
const RED_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/red_mana_icon.tscn")
const WHITE_MANA_ICON = preload("res://scene_prefabs/menus_and_guis/spellcraft_mana_icons/white_mana_icon.tscn")
#endregion

func _ready() -> void:
	# Initialise the Colour Tracker to all false
	# And the Mana Tracker to All Zeroes
	spellcraft_act = ActiveColourTracker.new(false, false, false, false, false)
	spellcraft_amt = ActiveManaTracker.new(0,0,0,0,0,0)
	
	# use the previously defined path strings to get access to various
	# HUD elements. This is pretty fragile and could probably be changed.
	gui_instances_container = player_hud.get_node_or_null(gui_instances_path)
	if(gui_instances_container == null):
		print("Could not find Mana Instance Container! Check paths in Spellcraft manager.")
	
	class_selector = player_hud.get_node_or_null(class_selector_path)
	if(class_selector == null):
		print("Could not find Spellcraft Class Selector! Check paths in Spellcraft manager.")

# TODO for every failcheck here (too much mana, too many colours, etc.)
# Add some in-game error messages rather than console prints.
func add_active_mana_instance(colour:MANA_COLOURS):
	# Main function body in each colour case is very similar and 
	# that means this can almost certainly be improved or refactored.
	# As such, comments are provided for Red case and no others.
	# TODO think about refactoring this to make it more readable/efficient. 
	# Unsure about different approaches though
	match colour:
		MANA_COLOURS.RED:
			# Catch fail cases first:
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
		# Behaviours as above for remaining mana colours:
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
	
	# Update the prefix dictionary every time new mana is added to
	# make sure that the resulting prefix has the right colour values.
	update_prefix_dict()

# TODO Remove the most recently added mana instance
# This will likely require a full refactor of how Active Mana is managed, 
# placing the Active Mana Instances into an array so that there 
# is a de facto undo-stack using pop_back()
func remove_last_instance():
	print("TODO Remove Last Mana Instance")

# Clear the player's current selection of mana completely
func clear_active_mana():
	# Mana and Colour Tracker classes have their own in-built reset functions
	spellcraft_act.reset()
	spellcraft_amt.reset()
	
	# Clear the active instances from the HUD
	# NOTE: function body for this is in /scripts/utils.gd
	var gui_instances = Utilities.get_child_nodes(gui_instances_container)
	for n in gui_instances:
		n.queue_free()

# Determine if the player's current selection results in a valid spell
# If it does, assign it to the corresponding spell slot.
func craft_and_bind(spell_index: int):
	#region Failchecks: 
	# Return straight out if insufficient components are provided.
	# TODO Add some in-game error pop-ups/ explanations in these cases when we get 
	# round to making a Playtest Build.
	if(spellcraft_act.total_active_colours == 0):
		print("Cannot craft Spell: not enough Mana Colours provided!") 
		return
	elif(spellcraft_amt.total_current_mana == 0):
		print("Cannot craft Spell: not enough total Mana added!")
		return
	elif(class_selector.current_class == SpellClassSelector.SPELL_CLASSES.NONE):
		print("Cannot craft Spell: no Spell Class selected!")
		return
	#endregion
	
	# Create new SpellSuffix instance and SpellPrefix Instance
	# based on Mana Inputs
	var crafted_spell_prefix:SpellPrefix = determine_prefix()
	var crafted_spell_suffix:SpellSuffix = determine_suffix()
	
	# Just a WIP catch-all, this can be removed when all 
	# prefixes and suffixes have been implemented
	if(crafted_spell_prefix == null || crafted_spell_suffix == null):
		print("Prefix or Suffix is Null. Check Debug Logs")
		menu_cleanup()
		return
	
	# Physically create the new Spell Instance
	var crafted_spell:Spell = Spell.new(player, crafted_spell_prefix, crafted_spell_suffix)
	
	# After checking if the spell is valid, make sure the player doesn't
	# already have it in a different spell slot. Must be a number check because
	# every crafted Spell is a new class instance.
	# [TODO This could potentially have other functionality, like
	# moving the existing spell to their chosen slot, or switching
	# the two spells around. Also probably want to refactor away from a name check.]
	for n in 4:
		if(player.active_spells[n] != null
		&& player.active_spells[n].spell_name == crafted_spell.spell_name):
			print("Already have that spell in slot " + var_to_str(n+1))
			return
	
	# All potential fail-cases have been accounted for by this point.
	# New Spell can be assigned to the associated spell slot passed in as a parameter
	# to this function.
	player.active_spells[spell_index] = crafted_spell
	#print("Spell Slot %d is now %s" %[spell_index, crafted_spell.spell_name])
	
	# Change GUI Spell Icon via the Hud Manager
	hud_manager.change_spell_icon(spell_index, crafted_spell_prefix.spell_icon_frame, crafted_spell_suffix.spell_icon)
	
	# And finally, clear and close the Spellcraft Menu
	menu_cleanup()

#---
# Helper Functions & Data Structures
#---

## Assign every possible colour combination to its corresponding prefix and exact mana values.
## This has to be called every time the player adds mana to their list.
## Questionably more efficient than just a big if-chain, but definitely
## more readable.
# TODO Run some internal speed tests to see which version is actually more performant
# between A) Constantly updating then reading from a dictionary. Worst case would be 5-mana Toxic
# or B) just doing an if-chain at the end. Worst case would be Mono-Black
func update_prefix_dict():
	prefix_dictionary = {
			# Mono-Colour Prefixes
			[true,false,false,false,false] : Blazing.new(spellcraft_amt.num_red, spellcraft_amt.num_colourless),
			[false,true,false,false,false] : Aqua.new(spellcraft_amt.num_blue, spellcraft_amt.num_colourless),
			[false,false,true,false,false] : Phyto.new(spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			[false,false,false,true,false] : Lumina.new(spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[false,false,false,false,true] : Umbral.new(spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			# Two-Colour Prefixes
			[true,true,false,false,false] : Steam.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_colourless),
			[true,false,true,false,false] : Carbon.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			[true,false,false,true,false] : Gigawatt.new(spellcraft_amt.num_red, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[true,false,false,false,true] : Infernal.new(spellcraft_amt.num_red, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[false,true,true,false,false] : Terra.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			[false,true,false,true,false] : Boreal.new(spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[false,true,false,false,true] : Hadal.new(spellcraft_amt.num_blue, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[false,false,true,true,false] : Floral.new(spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[false,false,true,false,true] : Fungal.new(spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[false,false,false,true,true] : Twilight.new(spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			# Three-Colour Prefixes
			[true,true,true,false,false] : Prismatic.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_colourless),
			[true,true,false,true,false] : Tempest.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[true,true,false,false,true] : BlackOil.new(spellcraft_amt.num_red, spellcraft_amt.num_blue, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[true,false,true,true,false] : Silica.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[true,false,true,false,true] : Ashen.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[true,false,false,true,true] : Thundercloud.new(spellcraft_amt.num_red, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
		
			[false,true,true,true,false] : Coral.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_colourless),
			[false,true,true,false,true] : Mire.new(spellcraft_amt.num_blue, spellcraft_amt.num_green, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
			
			[false,true,false,true,true] : Arctic.new(spellcraft_amt.num_blue, spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
		
			[false,false,true,true,true] : Toxic.new(spellcraft_amt.num_green, spellcraft_amt.num_white, spellcraft_amt.num_black, spellcraft_amt.num_colourless),
		}

func determine_prefix() -> SpellPrefix:
	var prefix : SpellPrefix = null
	
	# ActiveColourTracker has a custom Pass-By-Value getter so that
	# the player's instance can be compared directly with the keys
	# in the prefix_dictionary (which are Bool Arrays)
	prefix = prefix_dictionary[spellcraft_act.get_by_value()]
	
	if(prefix == null):
		print("No Prefix found in Dictionary for that Colour Combo! Double Check in spellcraft_manager.gd.")
		return

	return prefix

## This will definitely need refactoring and optimising,
## I'd really rather not have a million if/switch-chains
func determine_suffix() -> SpellSuffix:
	var suffix : SpellSuffix = null
	
	# Minor optimisation by returning out as soon as we find this.
	# Worst case, we have to check 14 options before returning out
	match(class_selector.current_class):
		SpellClassSelector.SPELL_CLASSES.TELUMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = BoltSuffix.new()
					#print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					#suffix = Spike.new()
					print("SPIKE not yet implemented.")
					return suffix
				3:
					#suffix = Beam.new()
					print("BEAM not yet implemented.")
					return suffix
				4:
					#suffix = Spear.new()
					print("SPEAR not yet implemented.")
					return suffix
				5:
					#suffix = Eruption.new()
					print("ERUPTION not yet implemented.")
					return suffix
		SpellClassSelector.SPELL_CLASSES.MOTOMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = StriderSuffix.new()
					#print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					#suffix = Transmission.new()
					print("TRANSMISSION not yet implemented.")
					return suffix
				3:
					#suffix = Leap.new()
					print("LEAP not yet implemented.")
					return suffix
				4:
					#suffix = Flight.new()
					print("FLIGHT not yet implemented.")
					return suffix
				5:
					#suffix = Blink.new()
					print("BLINK not yet implemented.")
					return suffix
		SpellClassSelector.SPELL_CLASSES.INSTRUMANCY:
			match(spellcraft_amt.total_current_mana):
				1:
					suffix = TransmutationSuffix.new()
					#print("Suffix Found: " + suffix.suffix_name)
					return suffix
				2:
					#suffix = Cloak.new()
					print("CLOAK not yet implemented.")
					return suffix
				3:
					#suffix = Barrier.new()
					print("BARRIER not yet implemented.")
					return suffix
				4:
					#suffix = Blade.new()
					print("BLADE not yet implemented.")
					return suffix
				5:
					#suffix = SummonFamiliar.new()
					print("SUMMON FAMILIAR not yet implemented.")
					return suffix
	
	if(suffix == null):
		print("No Suffix found that Class/Mana Combo! Double Check in spellcraft_manager.gd.")
		return
	
	return suffix

# Quick-access function to clear the player's selection and close the 
# Spellcraft Menu
func menu_cleanup():
	clear_active_mana()
	gsm.change_game_state(States.GAME_STATES.OVERWORLD)
	hud_manager.change_active_menu(0)
