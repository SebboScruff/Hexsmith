class Bolt extends SpellSuffix:
	
	func _init() -> void:
		suffix_name = "Bolt"
		
		cast_type = CAST_TYPES.CAST_WITH_COOLDOWN
		is_active = true
		target_type = TARGET_TYPES.RAW_DIRECTION
	
	func cast(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
		# Spell Functionality here:
		# Get Direction
		# Instantiate Bolt prefab with correct shader and
		# colour bonuses.
		# Start Cooldown.
		print("TODO Casted a BOLT Spell")
