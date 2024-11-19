# meta-name: Passive Spell
# meta-description: Spell Suffix with Passive Cast Type
# meta-default: true
# meta-space-indent: 4
class SuffixName extends SpellSuffix:
	
	func _init() -> void:
		suffix_name = "SuffixName"
		
		cast_type = CAST_TYPES.PASSIVE
		is_active = true
		target_type = TARGET_TYPES.SELF # Change this if required
	
	func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
		# Spell Functionality here:
		print("TODO {NAMEHERE} Spell is Active")
