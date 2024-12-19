## State Description Here!

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerCoyoteState
extends PlayerState

var direction:float

func _init() -> void:
	self.state_name = "Coyote Time" # This is used as the dictionary Key
	self.state_id = 18 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	State_Transition.emit(self, "fall", player.coyote_time) # Automatically start falling after a certain amount of time

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	if(Input.is_action_just_pressed("overworld_jump")):
		State_Transition.emit(self, "jump")
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
#endregion

#region PHYSICS BEHAVIOURS
	## Allow Horizontal Movement but do not apply gravity
	if(player.accept_movement_input):
		direction = Input.get_axis("overworld_move_left", "overworld_move_right")
		## NOTE: Function Body in base class, player_state.gd
		change_player_sprite_direction(direction)
		if(direction != 0):
			player.body_sprite.play("run")
			player.footstep_interval_timer.start()
		else:
			player.body_sprite.play("idle")
			player.footstep_interval_timer.stop()
		
		player._apply_horizontal_input(delta, direction)
#endregion

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	## Anything that has to happen as the player leaves this state goes here.
	## For example, resetting timescale, starting cooldowns, turning off bools, etc.
	## Remember that the next incoming state will have its on_enter() function called immediately
	## after this, so disabling animations or anything like that doesn't need to be put here.
	# pass
