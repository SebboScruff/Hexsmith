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
	# Set the player pause bool
	player.is_paused = true
	# Stop time in the game
	Engine.time_scale = 0
	# Open the pause menu
	hud_manager.change_active_menu(hud_manager.menu_hud)

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
	if(Input.is_action_just_pressed("global_system_pause")):
		# When unpausing, rather than resetting immediately to idle,
		# go back to whichever state the player was last in
		player.state_machine_runner.reset_to_previous_state()

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	## NOTE: Resetting to overworld hud and standard timescale here because
	## the FSM Runner's previous state may not set these in on_state_enter()
	hud_manager.change_active_menu(hud_manager.overworld_hud)
	Engine.time_scale = 1.0
	player.is_paused = false
