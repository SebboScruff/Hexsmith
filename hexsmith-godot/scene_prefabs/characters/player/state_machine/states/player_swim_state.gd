## Basic Swimming State, for when the player is within a Water Surface zone
## Transitions to 2 alternative Swimming States: Can Surface, and Underwater

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerSwimState
extends PlayerState

var movement_dir:Vector2
@export var max_height:float # This is set by water_area.gd upon entry into this state

func _init() -> void:
	self.state_name = "Swim" # This is used as the dictionary Key
	self.state_id = 10 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	player.current_speed = player.SWIM_SPEED
	player.gravity_scale = 0.5
	player.velocity = Vector2.ZERO # cancels all gravity-based velocity that may have stored up
	player.body_sprite.play("run") # TODO Change to Swim Animation when I have one.


## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)
	## NOTE: Oxygen Management is dealt with in player_controller.gd
	## alongsde other replenishable resources like Health and Mana.

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	## NOTE: State Transitions out of Swim State are done via collision
	## detection in water_area.gd
#endregion
#region PHYSICS BEHAVIOURS
	if(player.accept_movement_input):
		movement_dir.x = Input.get_axis("overworld_move_left", "overworld_move_right")
		change_player_sprite_direction(movement_dir.x)
		player._apply_horizontal_input(delta, movement_dir.x)
		
		movement_dir.y = Input.get_axis("overworld_up", "overworld_down")
		# As long as player is below the maximum height, allow free vertical movement.
		if(movement_dir.y != 0 && player.position.y >= max_height):
			# Cancel out gravity and replace with vertical swim speed
			player.velocity -= player.get_gravity() * delta * player.gravity_scale
			player._apply_vertical_input(delta, movement_dir.y)
		else:
			# Apply the (weakened) gravity to make the player sink
			player.velocity.y = player.get_gravity().y * delta * player.gravity_scale
#endregion

func on_state_exit() -> void:
	player.gravity_scale = 1.0
