## State Description Here!

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerPauseState
extends PlayerState

func _init() -> void:
	self.state_name = "Paused" # This is used as the dictionary Key
	self.state_id = 2 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	print("Player entered %s State"%[state_name])
	player.is_paused = true
	# pass

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
	if(Input.is_action_just_pressed("global_system_pause")):
		State_Transition.emit(self, "idle")

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	player.is_paused = false
	## Anything that has to happen as the player leaves this state goes here.
	## For example, resetting timescale, starting cooldowns, etc.
	## Remember that the next incoming state will have its on_enter() function called immediately
	## after this.
	# pass
