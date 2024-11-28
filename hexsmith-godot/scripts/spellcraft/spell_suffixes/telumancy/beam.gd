class_name BeamSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Beam"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.RAW_DIRECTION

func toggle():
	print("Toggled a BEAM Spell")
	
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	print("TODO BEAM Spell is Active")
