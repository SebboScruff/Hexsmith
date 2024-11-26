# 0: Mono-Red
class_name Blazing extends SpellPrefix

func _init(input_red:int, input_colourless:int):
	prefix_name = "Blazing"
	prefix_id = 0
	
	# Once spell frames are finished, load them in here. Switch out spell_slot_frame for the
	# .png file name.
	spell_icon_frame = preload(icon_frame_root_path + "blazing_frame.png")
	# NOTE: Colors declared as RGBA[0,1] so these are all defaulted opaque white
	colors = [
		Color(1,0,0,1), # Spell's Primary Color: Red
		Color(1,0.396,0,1), # Spell's Secondary Color: Orange
		Color(1,0.839,0,1), # Spell's Tertiary Color: Dark yellow
		Color(1,0.259,0.129,1), # Spell's Primary Effect Color (trails, particles, additional bits)
		Color(0.341,0.129,1,1) # Spell's Secondary Effect Color (trails, particles, additional bits)
	]
	# TODO Initialise Prefix Sound Effects.
	
	num_red_mana = input_red
	num_blue_mana = 0
	num_green_mana = 0
	num_white_mana = 0
	num_black_mana = 0
	num_colorless_mana = input_colourless
	print("Initialised BLAZING prefix with %d red and %d colorless"%[num_red_mana, num_colorless_mana])
