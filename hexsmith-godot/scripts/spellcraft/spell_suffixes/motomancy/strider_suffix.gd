## The Strider Suffix, when active, enables the player to have a variety of additional
## movement and walking-based powers added to their player body, depending on mana input:
## Red (Blazing Strider): Player's footsteps carry the Igniter tag, and interact with the Fire System 
## Blue (Aqua Strider): Player can walk on water surfaces as though they were solid land
## Green (Phyto Strider): Player moves much faster on Grassy Surfaces
## White (Lumina Strider): Player leaves little lights in their wake as they walk.
## Black (Noctis Strider): Player can briefly walk on nothing after leaving a platform

class_name StriderSuffix extends SpellSuffix

func _init() -> void:
	suffix_name = "Strider"
	
	cast_type = CAST_TYPES.TOGGLE
	active_state = false
	
	spell_icon = preload(icon_root_path + "strider_icon.png")

## Any special effects that happen when the spell is activated go here. For example,
## many Strider spells directly affect the player body in a number of ways when activated.
func on_activate(_mana_values:Array[float]) -> void:
	super.on_activate(_mana_values)
	
	# TODO Alter the player in a number of ways depending on mana input:
	# Red: Add Igniter object to bottom of player collider
	# Blue: Add Water Surfaces (i.e. Layer 6) to player's collision mask
	# Green: 
	# White: Spawn little light prefabs as the player walks (this can be done in on_passive_effect)
	# Black: Extend Coyote Time

## For removing any special effects that happened in on_toggle_on()
func on_deactivate(_mana_values:Array[float]) -> void:
	super.on_deactivate(_mana_values)
	
	# TODO Undo all the changes from on_activate.

func on_passive_effect(_delta:float, _mana_values:Array[float]):
	# change value of is_mana_cost_active based on A) mana inputs and B) other things:
	# NOTE: Reference player movement state machine here for easy access.
	# RED - on when moving, off when not moving
	# BLUE - on when standing/moving on water
	# GREEN - on when moving on grass, off otherwise
	# WHITE - on when moving, off when not moving
	# BLACK - on during Coyote Time, off otherwise
	pass
