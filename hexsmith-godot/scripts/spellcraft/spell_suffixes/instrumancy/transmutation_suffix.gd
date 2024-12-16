## The Transmutation Suffix causes the player to lose Mana of one colour, to 
## gain Mana of a Different colour. They gain the Mana Colour that was used as 
## Crafting Input, and lose whichever Mana is 'weak' to that colour, i.e.
## Red (Blazing Transmutation): Lose Green Mana to gain Red Mana
## Blue (Aqua Transmutation): Lose Red Mana to gain Blue Mana
## Green (Phyto Transmutation): Lose Blue Mana to gain Green Mana
## White (Lumina Transmutation): Lose Black Mana to gain White Mana
## Black (Noctis Transmutation): Lose White Mana to gain Black Mana
class_name TransmutationSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Transmutation"
	suffix_id = 10 # Very important for lookup tables.
	
	cast_type = CAST_TYPES.CHANNEL
	active_state = false
	base_mana_cost = 0 # Transmutation Spells do not have a Mana Cost in the traditional sense. Mana Manipulation is done via Activate and Deactivate effects.
	
	spell_icon = preload(icon_root_path + "transmutation_icon.png")

##NOTE: No Inheritance into set_active_state function so that base class implementation is used.

func on_activate(_mana_values:Array[float]) -> void:
	super.on_activate(_mana_values) ## Set active state using base class implementation
	
	# TODO Add to player's Mana Regeneration Values based on Mana Value Inputs

## For removing any special effects that happened in on_toggle_on()
func on_deactivate(_mana_values:Array[float]) -> void:
	super.on_deactivate(_mana_values) ## Set active state using base class implementation
	
	# TODO Remove the previously added Mana Regeneration based on Mana Value Inputs.

func on_passive_effect(_mana_values:Array[float]):
	# TODO If the mana bar is full, automatically toggle this off,
	# and return the player's Spellcast State Machine to IDLE.
	pass
