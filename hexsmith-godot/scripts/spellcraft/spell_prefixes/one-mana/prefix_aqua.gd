# 1: Mono-Blue
class_name Aqua extends SpellPrefix
func _init(input_blue:int, input_colourless:int):
	# Delete Parameters where appropriate. Do not remove input_colorless
	prefix_name = "Aqua"
	prefix_id = 1
	
	# Once spell frames are finished, load them in here. Switch out spell_slot_frame for the
	# .png file name.
	spell_icon_frame = preload(icon_frame_root_path + "aqua_frame.png")
	
	# NOTE: Colors declared as RGBA[0,1] so these are all defaulted opaque white
	colors = [
		Color(0.016,0,1,1), # Spell's Primary Color: dark blue
		Color(0.369,0.353,1,1), # Spell's Secondary Color: mid blue
		Color(0,0.878,1,1), # Spell's Tertiary Color: light blue
		Color(0.369,0.353,1,1), # Spell's Primary Effect Color (trails, particles, additional bits)
		Color(0.016,0,1,1) # Spell's Secondary Effect Color (trails, particles, additional bits)
	]
	# TODO Initialise Prefix Sound Effects.
	
	# NOTE: If any of the input parameters were removed, replace their values here with 0
	num_red_mana = 0
	num_blue_mana = input_blue
	num_green_mana = 0
	num_white_mana = 0
	num_black_mana = 0
	num_colorless_mana = input_colourless
