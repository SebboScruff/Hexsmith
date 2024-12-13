## When the player is fully submerged, this state is entered.
## Allows for free vertical movement, but drains the player's oxygen.

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerUnderwaterState
extends PlayerState

var movement_dir:Vector2

func _init() -> void:
	self.state_name = "Underwater" # This is used as the dictionary Key
	self.state_id = 12 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	# Activate oxygen reduction in the player resource management processing
	player.is_underwater = true

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	## NOTE: As with Swim State, transitions in and out of Underwater are dealt 
	## with via collision detection in water_area.gd.
#endregion

#region PHYSICS BEHAVIOURS
	movement_dir.x = Input.get_axis("overworld_move_left", "overworld_move_right")
	change_player_sprite_direction(movement_dir.x)
	
	movement_dir.y = Input.get_axis("overworld_up", "overworld_down")
	if(movement_dir.y != 0):
		# Cancel out gravity and replace with vertical swim speed
		player.velocity -= player.get_gravity() * delta * player.gravity_scale
		player._apply_horizontal_input(delta, movement_dir.x)
		player._apply_vertical_input(delta, movement_dir.y)
		player.move_and_slide()
	else:
		# Apply the (weakened) gravity to make the player sink
		player.velocity.y = player.get_gravity().y * delta * player.gravity_scale
		player._apply_horizontal_input(delta, movement_dir.x)
		player.move_and_slide()
#endregion

func on_state_exit() -> void:
	print("Player exited %s State"%[state_name])
	player.is_underwater = false
