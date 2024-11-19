# Script for controlling the game's current menu state:
# Used for managing direct transitions between different HUD parent objects.
# More indirect effects, like altering the game's time state, is done in
# game_state_manager.gd
class_name HudManager
extends CanvasLayer

@onready var overworld_hud: Control = %overworld_hud	# index 0
@onready var spellcraft_hud: Control = %spellcraft_hud	# index 1
@onready var menu_hud: Control = %menu_hud				# index 2

var current_active_menu
	
# Load up the Overworld HUD on Start
func _ready() -> void:
	change_active_menu(0)

# Deactivate all menus, then reactivate the one that is passed
# as a parameter.
# TODO make this less shit
func change_active_menu(new_menu_index:int) -> void:
	deactivate_hud_group(overworld_hud)
	deactivate_hud_group(spellcraft_hud)
	deactivate_hud_group(menu_hud)
	
	# TODO Definitely need to get rid of these magic numbers at some point
	match new_menu_index:
		0:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			activate_hud_group(overworld_hud)
		1:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			activate_hud_group(spellcraft_hud)
		2:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			activate_hud_group(menu_hud)
		_:
			print("Attempted to change to menu with invalid index. Check HudManager array.")
			return

func activate_hud_group(parent:Control):
	parent.set_process(true)
	parent.set_visible(true)

func deactivate_hud_group(parent:Control):
	parent.set_process(false)
	parent.set_visible(false)
