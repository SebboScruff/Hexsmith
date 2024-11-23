class_name FlightSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Flight"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = false
	target_type = TARGET_TYPES.RAW_DIRECTION

func toggle():
	print("Toggled a FLIGHT Spell")
	
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality Here:
	print("TODO FLIGHT Spell is Active")
