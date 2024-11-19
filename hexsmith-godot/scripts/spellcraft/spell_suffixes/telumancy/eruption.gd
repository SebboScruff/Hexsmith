class_name Eruption extends SpellSuffix

func _init() -> void:
	suffix_name = "Eruption"
	
	cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
	is_active = true
	target_type = TARGET_TYPES.RAW_DIRECTION

func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality here:
	print("TODO Casted an ERUPTION Spell")
