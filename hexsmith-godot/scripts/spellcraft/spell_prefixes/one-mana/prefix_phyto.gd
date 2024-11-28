# 2: Mono_Green
class_name Phyto extends SpellPrefix 
func _init(input_green:int, input_colourless:int):
	# Delete Parameters where appropriate. Do not remove input_colorless
	prefix_name = "Phyto"
	prefix_id = 2
	
	# Once spell frames are finished, load them in here. Switch out spell_slot_frame for the
	# .png file name.
	spell_icon_frame = preload(icon_frame_root_path + "phyto_frame.png")
	# NOTE: Colors declared as RGBA[0,1] so these are all defaulted opaque white
	colors = [
		Color(0,1,0,1), # Spell's Primary Color
		Color(1,1,1,1), # Spell's Secondary Color
		Color(1,1,1,1), # Spell's Tertiary Color
		Color(0.329,0.561,0.157,1), # Spell's Primary Effect Color (trails, particles, additional bits)
		Color(1,1,1,1) # Spell's Secondary Effect Color (trails, particles, additional bits)
	]
	# TODO Initialise Prefix Sound Effects.
	
	# NOTE: If any of the input parameters were removed, replace their values here with 0
	num_red_mana = 0
	num_blue_mana = 0
	num_green_mana = input_green
	num_white_mana = 0
	num_black_mana = 0
	num_colorless_mana = input_colourless
