## State Description Here!

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerSwimState
extends PlayerState

# Player has free vertical movement while swimming
var movement_dir:Vector2

func _init() -> void:
	self.state_name = "Swim" # This is used as the dictionary Key
	self.state_id = 10 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	print("Player entered %s State"%[state_name])
	player.current_speed = player.SWIM_SPEED
	player.gravity_scale = 0.5
	player.velocity = Vector2.ZERO # cancels all gravity-based velocity that may have stored up
	player.body_sprite.play("run")
	# pass

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)
	# TODO Oxygen Management

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	if(Input.is_action_pressed("overworld_jump") && player.can_surface):
		State_Transition.emit(self, "jump")
#endregion
#region PHYSICS BEHAVIOURS
	movement_dir.x = Input.get_axis("overworld_move_left", "overworld_move_right")
	change_player_sprite_direction(movement_dir.x)
	movement_dir.y = Input.get_axis("overworld_up", "overworld_down")
	if(movement_dir.y != 0):
		# Cancel out gravity and replace with vertical swim speed
		player.velocity -= player.get_gravity() * delta * player.gravity_scale
		player._apply_movement(delta, movement_dir.x, movement_dir.y)
	else:
		# Apply the (weakened) gravity to make the player sink
		player.velocity.y = player.get_gravity().y * delta * player.gravity_scale
		player._apply_movement(delta, movement_dir.x)
#endregion

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	player.gravity_scale = 1.0
	## Anything that has to happen as the player leaves this state goes here.
	## For example, resetting timescale, starting cooldowns, turning off bools, etc.
	## Remember that the next incoming state will have its on_enter() function called immediately
	## after this.
	# pass
