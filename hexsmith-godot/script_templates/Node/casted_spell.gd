# meta-name: Casted Spell
# meta-description: Spell Suffix with CAST-WITH-COOLDOWN Cast Type
# meta-default: true
# meta-space-indent: 4
class SuffixName extends SpellSuffix:
	
	func _init() -> void:
		suffix_name = "SuffixName"
		
		cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
		is_active = true
		target_type = TARGET_TYPES.RAW_DIRECTION # Change this if required
	
	func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
		# Spell Functionality here:
		print("TODO Casted a {NAMEHERE} Spell")
