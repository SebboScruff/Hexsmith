## When the player is fully submerged, this state is entered.
## Allows for free vertical movement, but drains the player's oxygen.

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerUnderwaterState
extends PlayerSwimState

func _init() -> void:
	self.state_name = "Underwater" # This is used as the dictionary Key
	self.state_id = 12 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	# Activate oxygen reduction in the player resource management processing
	super.on_state_enter()
	player.is_underwater = true

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	## NOTE: As with Swim State, state transitions are dealt with via collision
	## detection in water_area.gd
#endregion

#region PHYSICS BEHAVIOURS
	## NOTE: Inherits from Swim State, and uses its physics process behaviours.
#endregion

func on_state_exit() -> void:
	super.on_state_exit()
	player.is_underwater = false
