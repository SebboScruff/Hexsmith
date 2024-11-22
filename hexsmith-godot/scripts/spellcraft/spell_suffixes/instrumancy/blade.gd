class_name Blade extends SpellSuffix

func _init() -> void:
	suffix_name = "Blade"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.SELF

func toggle():
	print("Toggled a BLADE Spell")
	
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	print("TODO BLADE Spell is Active")
