class_name TransmutationSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Transmutation"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.SELF
	
	spell_icon = preload(icon_root_path + "transmutation_icon.png")

func toggle():
	print("Toggled a TRANSMUTATION Spell")
	
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	# Toggle off all other Transmutation Spells in the player's Active Spell List.
	# Depending on Mana Input, increase or decrease player's mana regen.
	print("TODO TRANSMUTATION Spell is Active")
