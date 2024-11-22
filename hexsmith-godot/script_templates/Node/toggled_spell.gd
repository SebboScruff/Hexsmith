# meta-name: Toggled Spell
# meta-description: Spell Suffix with TOGGLE Cast Type
# meta-default: true
# meta-space-indent: 4
class SuffixName extends SpellSuffix:
	
	func _init() -> void:
		suffix_name = "SuffixName"
		
		cast_type = CAST_TYPES.TOGGLE
		is_active = false
		target_type = TARGET_TYPES.RAW_DIRECTION # Change this if required
	
	func toggle():
		print("Toggled a {NAMEHERE} Spell")
		
	func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
		# Spell Functionality Here:
		print("TODO {NAMEHERE} Spell is Active")
