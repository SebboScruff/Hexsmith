class_name TransmutationSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Transmutation"
	suffix_id = 10 # Very important for lookup tables.
	
	cast_type = CAST_TYPES.PRESS_AND_HOLD
	is_active = false
	target_type = TARGET_TYPES.SELF
	base_mana_cost = -5 # Transmutation has a negative Mana Cost because it increases Mana Regeneration while active.
	
	spell_icon = preload(icon_root_path + "transmutation_icon.png")

# NOTE: No inherited behaviours for set_active()
# so that base class's method is used

@warning_ignore("unused_parameter")
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	pass
