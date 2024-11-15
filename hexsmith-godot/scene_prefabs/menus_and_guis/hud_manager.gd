extends CanvasLayer

@onready var overworld_hud: Control = $overworld_hud
@onready var spellcraft_hud: Control = $spellcraft_hud
@onready var menu_hud: Control = $menu_hud

var current_active_menu

# Load up the Overworld HUD on Start
func _ready() -> void:
	change_active_menu(overworld_hud)


# Deactivate all menus, then reactivate the one that is passed
# as a parameter.
func change_active_menu(new_active_menu) -> void:
	overworld_hud.set_process(false)
	spellcraft_hud.set_process(false)
	menu_hud.set_process(false)
	
	match(new_active_menu):
		overworld_hud:
			overworld_hud.set_process(true)
		spellcraft_hud:
			spellcraft_hud.set_process(true)
		menu_hud:
			menu_hud.set_process(true)
		_:
			print("Attempted to activate nonexistent menu!")
	
