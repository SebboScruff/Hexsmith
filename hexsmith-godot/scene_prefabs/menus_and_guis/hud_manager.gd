# Script for controlling the game's current menu state:
# Used for managing direct transitions between different HUD parent objects.
# More indirect effects, like altering the game's time state, is done in
# game_state_manager.gd

# This class is also used for adjusting the values shown on the HUD - whether that's 
# adding or removing mana, 
class_name HudManager
extends CanvasLayer

# HUD PARENTS
@onready var overworld_hud: Control = %overworld_hud	# index 0
@onready var spellcraft_hud: Control = %spellcraft_hud	# index 1
@onready var menu_hud: Control = %menu_hud				# index 2

var current_active_menu

# OVERWORLD HUD ASPECTS
@export var spell_icons : Array[SpellIcon]

## TODO Implement Mana Bars in here.
#var mana_bars : Array[ManaValueTracker]
	
# Load up the Overworld HUD on Start
func _ready() -> void:
	change_active_menu(overworld_hud)
	
	# Load up the Spell Icon arrays
	# TODO This is awful to look at and extremely fragile, definitely refactor this
	spell_icons = [overworld_hud.get_node("spell_slots_container/spell_slots_grid/SpellIcon1") as SpellIcon,
	overworld_hud.get_node("spell_slots_container/spell_slots_grid/SpellIcon2") as SpellIcon,
	overworld_hud.get_node("spell_slots_container/spell_slots_grid/SpellIcon3") as SpellIcon,
	overworld_hud.get_node("spell_slots_container/spell_slots_grid/SpellIcon4") as SpellIcon]
	
# Deactivate all menus, then reactivate the one that is passed
# as a parameter.
# TODO try to do this in a marginally less horrible way
func change_active_menu(new_menu_parent:Control) -> void:
	deactivate_hud_group(overworld_hud)
	deactivate_hud_group(spellcraft_hud)
	deactivate_hud_group(menu_hud)
	
	# TODO Definitely need to get rid of these magic numbers at some point
	activate_hud_group(new_menu_parent)

func activate_hud_group(parent:Control):
	parent.set_process(true)
	parent.set_visible(true)

func deactivate_hud_group(parent:Control):
	parent.set_process(false)
	parent.set_visible(false)

# Sets the Texture for both the Frame and Icon at the target index.
# Spell Slot 1 has index 0, Slot 2 => index 1, etc.
func change_spell_icon(_index:int, _frame:CompressedTexture2D, _icon:CompressedTexture2D) -> void:
	if(spell_icons[_index] == null):
		print("Spell Icons were not correctly assigned. Breaking out of GUI Assignment.")
		return
	
	spell_icons[_index].set_icon(_icon)
	spell_icons[_index].set_frame(_frame)

func set_spell_slot_highlight(_index:int, _new_highlight_state:bool):
	if(spell_icons[_index] == null):
		print("Spell Icons were not correctly assigned. Breaking out of GUI Assignment.")
		return
	
	if(_new_highlight_state == true):
		# TODO Enable the visual border that shows the spell as "currently active"
		pass
	else:
		# TODO Disable the visual border that shows the spell as "currently active"
		pass
