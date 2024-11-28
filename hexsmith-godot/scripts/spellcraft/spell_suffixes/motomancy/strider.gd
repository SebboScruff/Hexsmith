class_name StriderSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Strider"
	
	cast_type = CAST_TYPES.PASSIVE
	is_active = true
	target_type = TARGET_TYPES.SELF
	
	spell_icon = preload(icon_root_path + "strider_icon.png")

func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	# Spell Functionality here:
	# Depending on input manas, activate or deactivate a
	# variety of hitboxes or sub-nodes on the player prefab
	print("TODO STRIDER Spell is Active")
