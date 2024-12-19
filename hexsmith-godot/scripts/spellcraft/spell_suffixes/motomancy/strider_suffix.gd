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
	
	## For Toggles, this is generally per second and should be relatively low.
	base_mana_cost = 20
	
	spell_icon = preload(icon_root_path + "strider_icon.png")

## Any special effects that happen when the spell is activated go here. For example,
## many Strider spells directly affect the player body in a number of ways when activated.
func on_activate(_mana_values:Array[float]) -> void:
	super.on_activate(_mana_values)
	
	# TODO Alter the player in a number of ways depending on mana input:
	## RED - Add an igniter Fire System Entity to the player's feet
	if(_mana_values[0] > 0):
		pass
	## BLUE - alter the player's collision mask so they collide with Water Surface (layer 6)
	elif(_mana_values[1] > 0):
		player.set_collision_mask_value(6, true)
	## GREEN - idk
	elif(_mana_values[2] > 0):
		pass
	## WHITE - regularly instantiate little lights at the player's feet
	elif(_mana_values[3] > 0):
		pass
	## BLACK - extend Coyote Time Duration to 1.5s
	elif(_mana_values[4] > 0):
		player.coyote_time = 1.5

## For removing any special effects that happened in on_toggle_on()
func on_deactivate(_mana_values:Array[float]) -> void:
	super.on_deactivate(_mana_values)
	
	## RED - Remove the Igniter Fire System Entity to the player's feet
	if(_mana_values[0] > 0):
		pass
	## BLUE - alter the player's collision mask so they don't collide with Water Surface (layer 6)
	elif(_mana_values[1] > 0):
		player.set_collision_mask_value(6, false)
	## GREEN - idk
	elif(_mana_values[2] > 0):
		pass
	## WHITE - Stop making lights
	elif(_mana_values[3] > 0):
		pass
	## BLACK - reset Coyote Time Duration
	elif(_mana_values[4] > 0):
		player.coyote_time = player.BASE_COYOTE_TIME

func on_passive_effect(_delta:float, _mana_values:Array[float]):
	# change value of is_mana_cost_active based on A) mana inputs and B) other things:
	# NOTE: Reference player movement state machine here for easy access.
	
	## RED - on when moving, off when not moving
	if(_mana_values[0] > 0):
		if(player.velocity.x != 0):
			is_mana_cost_active = true
		else:
			is_mana_cost_active = false
	## BLUE - on when standing/moving on water
	elif(_mana_values[1] > 0):
		if(player.underfoot_raycast.get_collision_mask_value(6)):
			is_mana_cost_active = true
		else:
			is_mana_cost_active = false
	## GREEN - on when moving on grass, off otherwise
	elif(_mana_values[2] > 0):
		pass
	## WHITE - on when moving on the ground, off when not moving
	elif(_mana_values[3] > 0):
		if(player.is_on_floor() && player.velocity.x != 0):
			is_mana_cost_active = true
		else:
			is_mana_cost_active = false
	## BLACK - on during Coyote Time, off otherwise
	elif(_mana_values[4] > 0):
		if(player.movement_state_machine.get_current_state_name() == "coyote time"):
			is_mana_cost_active = true
		else:
			is_mana_cost_active = false
