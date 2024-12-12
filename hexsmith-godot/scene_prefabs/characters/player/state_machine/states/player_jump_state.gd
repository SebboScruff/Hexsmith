## The Jump State, that applies a vertical acceleration and then switches to falling
## (or in edge cases, into Climbing/Idle/etc. depending on where the jump ends up.)

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerJumpState
extends PlayerState

var h_dir:float

func _init() -> void:
	self.state_name = "Jump" # This is used as the dictionary Key
	self.state_id = 7 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	print("Player entered %s State"%[state_name])
	# Here is stuff like setting player speed, gravity scale, 
	# and calling animations.
	if(player.velocity.y >= 0):
		player.body_sprite.play("jump_start")
		player.velocity.y = player.JUMP_VELOCITY

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	# Fall if moving downwards
	if(!player.is_on_floor() && player.velocity.y > 0):
		State_Transition.emit(self, "fall")
	elif(player.is_on_floor()):
		State_Transition.emit(self, "idle")
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
#endregion

#region PHYSICS BEHAVIOURS
	h_dir = Input.get_axis("overworld_move_left", "overworld_move_right")
	change_player_sprite_direction(h_dir)
	player._apply_gravity(delta)
	player._apply_movement(delta, h_dir)
#endregion

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	## Anything that has to happen as the player leaves this state goes here.
	## For example, resetting timescale, starting cooldowns, turning off bools, etc.
	## Remember that the next incoming state will have its on_enter() function called immediately
	## after this, so disabling animations or anything like that doesn't need to be put here.
	# pass
