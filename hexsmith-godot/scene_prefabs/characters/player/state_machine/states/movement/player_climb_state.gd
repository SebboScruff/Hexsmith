## The Climbing State, for when the player is on a ladder or scaleable wall.

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerClimbState
extends PlayerState

var movement_dir:Vector2

func _init() -> void:
	self.state_name = "Climb" # This is used as the dictionary Key
	self.state_id = 9 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	player.body_sprite.play("idle")
	player.gravity_scale = 0

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
	
#region STATE TRANSITIONS
	if(!player.is_climbing):
		if(player.is_on_floor()):
			State_Transition.emit(self, "idle")
		elif(Input.is_action_just_pressed("overworld_jump")):
			State_Transition.emit(self, "jump")
		else:
			State_Transition.emit(self, "coyote time")
#endregion

#region PHYSICS BEHAVIOURS
	if(player.accept_movement_input):
		player._apply_horizontal_input(delta, movement_dir.x)
		player._apply_vertical_input(delta, movement_dir.y)
		movement_dir.x = Input.get_axis("overworld_move_left", "overworld_move_right")
		movement_dir.y = Input.get_axis("overworld_up", "overworld_down")
		change_player_sprite_direction(movement_dir.x)
#endregion

func on_state_exit() -> void:
	player.gravity_scale = 1.0
