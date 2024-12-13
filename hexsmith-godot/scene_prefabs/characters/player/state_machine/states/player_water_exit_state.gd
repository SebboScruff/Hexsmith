## State Description Here!

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerWaterExitState
extends PlayerSwimState

func _init() -> void:
	self.state_name = "Water Exit" # This is used as the dictionary Key
	self.state_id = 11 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	super.on_state_enter() # perform all the same entry processes as Swim

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	# The only difference between Swim and Water Exit is that players can jump 
	# out of the water in Water Exit. TODO Probably just change this into a bool in Swim rather
	# than an entirely different state.
	if(Input.is_action_just_pressed("overworld_jump")):
		State_Transition.emit(self, "jump")
#endregion

#region PHYSICS BEHAVIOURS
	## NOTE: Standard swim behaviours are called via super.on_state_physics_process
#endregion

func on_state_exit() -> void:
	super.on_state_exit()
