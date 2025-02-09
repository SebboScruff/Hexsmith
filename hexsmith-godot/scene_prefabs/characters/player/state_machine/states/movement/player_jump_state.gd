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
var jump_velocity:float

func _init() -> void:
	self.state_name = "Jump" # This is used as the dictionary Key
	self.state_id = 7 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	## Depending on which state the player is exiting from, the Jump Velocity
	## has to be adjusted. Can disable the jump altogether.
	match(player.movement_state_machine.get_previous_state_name()):
		"paused":
			jump_velocity = 0 # Disable the jump if exiting out of a Pause to avoid the Sonic Frontiers Bug
		"swim":
			jump_velocity = -100 # Weaken the jump force if jumping out of water
		_:
			jump_velocity = -200.0 # Default the jump to its regular value
	
	player.velocity.y += jump_velocity

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
	# If the player somehow jumps directly up onto a floor, go straight to idle
	elif(player.is_on_floor()):
		State_Transition.emit(self, "idle")
	# If the player jumps into a climb zone, go straight to climb
	elif(player.is_in_climb_zone):
		State_Transition.emit(self, "climb")
#endregion

#region PHYSICS BEHAVIOURS
	player._apply_gravity(delta)
	if(player.accept_movement_input):
		h_dir = Input.get_axis("overworld_move_left", "overworld_move_right")
		change_player_sprite_direction(h_dir)
		player._apply_horizontal_input(delta, h_dir)
#endregion

func on_state_exit() -> void:
	# No behaviours needed for exiting Jump state.
	pass
