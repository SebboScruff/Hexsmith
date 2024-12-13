## Any time the player is in free-fall: walking off a ledge, after jumping, 
## after being knocked upwards, or any other effect. 

## NOTE:
## Perform a State Transitions with State_Transition.emit(self, "new_state_name")
## Play animations on the player with player.body_sprite.play("animation_name")
## Manipulate movement with player.gravity_scale and player.current_speed.
## Activate movement per frame with player._apply_gravity and player._apply_movement()

class_name PlayerFallState
extends PlayerState

var h_dir:float

func _init() -> void:
	self.state_name = "Fall" # This is used as the dictionary Key
	self.state_id = 8 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	player.body_sprite.play("jump_land")

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	# 1 - Idle
	if(player.is_on_floor()):
		State_Transition.emit(self, "idle")
	# 2 - Climb
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
	# 3 - Swim
	elif(player.is_swimming):
		State_Transition.emit(self, "swim")
	# 4 - Spellcasting
	check_spellcast_transitions() ## NOTE: Function Body in base class, player_state.gd
#endregion

#region PHYSICS BEHAVIOURS
	h_dir = Input.get_axis("overworld_move_left", "overworld_move_right")
	change_player_sprite_direction(h_dir)
	
	player._apply_gravity(delta)
	player._apply_horizontal_input(delta, h_dir)
	player.move_and_slide()
#endregion

func on_state_exit() -> void:
	# No behaviours needed for exiting Fall state.
	pass