## The Focus Suffix causes increases the player's regen rate for the input color, 
## but stops them from moving (since it is a Channelled Spell).
## Red (Blazing Focus): Gain Red Mana
## Blue (Aqua Focus): Gain Blue Mana
## Green (Phyto Focus): Gain Green Mana
## White (Lumina Focus): Gain White Mana
## Black (Noctis Focus): Gain Black Mana
class_name FocusSuffix extends SpellSuffix

const REGEN_INCREASE := 10.0 # How much mana is gained per second.
const AUTO_EXIT_MESSAGE := "Mana is full! Automatically ending Focus Spell!" # printout message if the spell is auto cancelled

func _init() -> void:
	suffix_name = "Focus"
	suffix_id = 10 # Very important for lookup tables.
	
	cast_type = CAST_TYPES.CHANNEL
	active_state = false
	# NOTE: Transmutation Spells do not have a Mana Cost in the traditional sense. 
	# Mana Manipulation is done via Activate and Deactivate effects.
	base_mana_cost = 0
	
	spell_icon = preload(icon_root_path + "focus_icon.png")

##NOTE: No Inheritance into set_active_state function so that base class implementation is used.

# TODO There is definitely a more elegant way to do this
func on_activate(_mana_inputs:Array[float]) -> void:
	super.on_activate(_mana_inputs) ## Set active state using base class implementation
	
	## Increase Mana Regen Rates by Mana Input Values
	player.mana_value_trackers[0].mana_regen_rate += REGEN_INCREASE * _mana_inputs[0] # Increase Red Regen by Red Input
	player.mana_value_trackers[1].mana_regen_rate += REGEN_INCREASE * _mana_inputs[1] # Increase Blue Regen by Blue Input
	player.mana_value_trackers[2].mana_regen_rate += REGEN_INCREASE * _mana_inputs[2] # Increase Green Regen by Green Input
	player.mana_value_trackers[3].mana_regen_rate += REGEN_INCREASE * _mana_inputs[3] # Increase White Regen by White Input
	player.mana_value_trackers[4].mana_regen_rate += REGEN_INCREASE * _mana_inputs[4] # Increase Black Regen by Black Input

## For removing any special effects that happened in on_toggle_on()
func on_deactivate(_mana_inputs:Array[float]) -> void:
	super.on_deactivate(_mana_inputs) ## Set active state using base class implementation
	
	## Undo Regen Increases
	player.mana_value_trackers[0].mana_regen_rate -= REGEN_INCREASE * _mana_inputs[0]
	player.mana_value_trackers[1].mana_regen_rate -= REGEN_INCREASE * _mana_inputs[1]
	player.mana_value_trackers[2].mana_regen_rate -= REGEN_INCREASE * _mana_inputs[2]
	player.mana_value_trackers[3].mana_regen_rate -= REGEN_INCREASE * _mana_inputs[3]
	player.mana_value_trackers[4].mana_regen_rate -= REGEN_INCREASE * _mana_inputs[4]

func on_passive_effect(_delta:float, _mana_inputs:Array[float]):
	## If either the increasing mana bar is full, or the decreasing bar
	## is empty, automatically toggle this off, and return the player's
	## Spellcast State Machine to IDLE.
	
	if(_mana_inputs[0] > 0): # i.e. Blazing Focus
		if(player.mana_value_trackers[0].current_mana >= player.mana_value_trackers[0].maximum_mana):
			print(AUTO_EXIT_MESSAGE)
			set_active_state(false, _mana_inputs)
			player.spellcast_state_machine.reset_to_idle()
		
	elif(_mana_inputs[1] > 0): # i.e. Aqua Focus
		if(player.mana_value_trackers[1].current_mana >= player.mana_value_trackers[1].maximum_mana):
			print(AUTO_EXIT_MESSAGE)
			set_active_state(false, _mana_inputs)
			player.spellcast_state_machine.reset_to_idle()
		
	elif(_mana_inputs[2] > 0): # i.e. Phyto Focus
		if(player.mana_value_trackers[2].current_mana >= player.mana_value_trackers[2].maximum_mana):
			print(AUTO_EXIT_MESSAGE)
			set_active_state(false, _mana_inputs)
			player.spellcast_state_machine.reset_to_idle() 
		
	elif(_mana_inputs[3] > 0): # i.e. Lumina Focus
		if(player.mana_value_trackers[3].current_mana >= player.mana_value_trackers[3].maximum_mana):
			print(AUTO_EXIT_MESSAGE)
			set_active_state(false, _mana_inputs)
			player.spellcast_state_machine.reset_to_idle()
		
	elif(_mana_inputs[3] > 0): # i.e. Noctis Focus
		if(player.mana_value_trackers[3].current_mana >= player.mana_value_trackers[3].maximum_mana):
			print(AUTO_EXIT_MESSAGE)
			set_active_state(false, _mana_inputs)
			player.spellcast_state_machine.reset_to_idle()
