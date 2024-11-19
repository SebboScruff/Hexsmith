class_name Transmutation extends SpellSuffix

func _init() -> void:
	suffix_name = "Transmutation"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.SELF

func toggle():
	print("Toggled a TRANSMUTATION Spell")
	
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	# Toggle off all other Transmutation Spells in the player's Active Spell List.
	# Depending on Mana Input, increase or decrease player's mana regen.
	print("TODO TRANSMUTATION Spell is Active")
