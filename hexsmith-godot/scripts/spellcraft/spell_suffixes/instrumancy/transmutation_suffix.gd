class_name TransmutationSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Transmutation"
	suffix_id = 10 # Very important for lookup tables.
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.SELF
	base_mana_cost = 5 # For Transmutation specifically, this is the amount gained and lost per second
	
	spell_icon = preload(icon_root_path + "transmutation_icon.png")

# NOTE: No inherited behaviours for set_active()
# so that base class's method is used

func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	# Depending on Mana Input, increase or decrease player's mana regen.
	# Changes Green to Red, Red to Blue, Blue to Green,
	# White to Black, or Black to White
	pass
