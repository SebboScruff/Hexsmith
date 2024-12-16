## Stops the player from doing any spellcasting. Entered upon entering the Spellcraft Menu
## exited a short while thereafter to prevent the player from inputting Spellcast Inputs while not allowed.
## Could also be accessed by various bosses or traps to prevent the player from casting spells 
## for a short while


class_name PlayerNoCastState
extends PlayerState

func _init() -> void:
	self.state_name = "No Cast" # This is used as the dictionary Key
	self.state_id = 17 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	## TODO Could maybe create a visual effect to indicate this state.
	pass

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	
#endregion

#region PHYSICS BEHAVIOURS
	
#endregion

func on_state_exit() -> void:
	pass
