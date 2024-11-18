# Script for controlling the game's current menu state:
# Used for managing direct transitions between different HUD parent objects.
# More indirect effects, like altering the game's time state, is done in
# game_state_manager.gd

extends CanvasLayer

@onready var overworld_hud: Control = %overworld_hud
@onready var spellcraft_hud: Control = %spellcraft_hud
@onready var menu_hud: Control = %menu_hud

var current_active_menu

# Load up the Overworld HUD on Start
func _ready() -> void:
	change_active_menu(overworld_hud)

func _input(event: InputEvent) -> void:
	pass

# Deactivate all menus, then reactivate the one that is passed
# as a parameter.
# TODO clean this up - I'm sure there's a neater and more efficient way to
# have this exact effect
func change_active_menu(new_active_menu) -> void:
	deactivate_hud_group(overworld_hud)
	deactivate_hud_group(spellcraft_hud)
	deactivate_hud_group(menu_hud)
	
	match(new_active_menu):
		overworld_hud:
			activate_hud_group(overworld_hud)
		spellcraft_hud:
			activate_hud_group(spellcraft_hud)
		menu_hud:
			activate_hud_group(menu_hud)
		_:
			print("Attempted to activate nonexistent menu!")

func activate_hud_group(parent: Control):
	parent.set_process(true)
	parent.set_visible(true)

func deactivate_hud_group(parent: Control):
	parent.set_process(false)
	parent.set_visible(false)
