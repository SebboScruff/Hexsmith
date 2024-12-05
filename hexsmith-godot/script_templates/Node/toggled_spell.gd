# meta-name: Toggled Spell
# meta-description: Spell Suffix with TOGGLE Cast Type
# meta-default: true
# meta-space-indent: 4
class_name ToggledSuffix extends SpellSuffix
	
func _init() -> void:
	suffix_name = "SuffixName"
	suffix_id = 0 # Very important for lookup tables.
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.SELF # Change this if required
	base_mana_cost = 0 # NOTE: For Toggled Spells, this is Mana Cost Per Second, Per Color Instance

# NOTE: No inherited behaviours for set_active()
# so that base class's method is used

func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	print("TODO {NAMEHERE} Spell is Active")
