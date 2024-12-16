class_name StriderSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Strider"
	
	cast_type = CAST_TYPES.TOGGLE
	is_active = true
	target_type = TARGET_TYPES.SELF
	
	spell_icon = preload(icon_root_path + "strider_icon.png")

func on_toggle_on(mana_values:Array[float]) -> void:
	pass
func on_toggle_off(mana_values:Array[float]) -> void:
	pass

@warning_ignore("unused_parameter")
func do_effect(num_red:int, num_blue:int, 
num_green:int, num_white:int, num_black:int, 
num_colourless:int):
	## Set up as Elif Chain for now because this spell can only ever have 1 mana in it.
	## Actual Strider effects on the player are managed in the on_toggle functions above; this
	## just determines when the spell should drain mana.
	if(num_red > 0):
		pass
	elif(num_blue > 0):
		pass
	elif(num_green > 0):
		pass
	elif(num_white > 0):
		pass
	elif(num_black > 0):
		pass
