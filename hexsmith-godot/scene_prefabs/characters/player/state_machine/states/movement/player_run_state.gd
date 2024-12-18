## Faster grounded movement than walking. May be deleted in the future depending on 
## a couple of factors:
## A) How much I need the Shift Key/ can get away with Axis Strength on controllers
## B) Whether or not I can think of a compelling reason to make the player use both speeds at 
## different points in the game. Don't really wanna just use stamina
## However I could implement this into some artificial Speed Boosts like Phyto Strider

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerRunState
extends PlayerState

var direction:float

func _init() -> void:
	self.state_name = "Run" # This is used as the dictionary Key
	self.state_id = 6 # Check Obsidian for IDs; these are maybe not useful.

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	player.current_speed = player.RUN_SPEED
	player.body_sprite.play("run")
	

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	# Idle
	if(Input.get_axis("overworld_move_left", "overworld_move_right") == 0):
		State_Transition.emit(self, "idle")
	# Walk
	elif(Input.is_action_just_released("overworld_toggle_sprint")):
		State_Transition.emit(self, "walk")
	# Jump
	elif(Input.is_action_just_pressed("overworld_jump")):
		State_Transition.emit(self, "jump")
	# Fall
	elif(!player.is_on_floor()):
		State_Transition.emit(self, "coyote time")
	# Crawl
	elif(player.is_on_floor() && Input.is_action_just_pressed("overworld_down")):
		State_Transition.emit(self, "crawl")
	# Climb
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
#endregion

#region PHYSICS BEHAVIOURS
	player._apply_gravity(delta)
	
	if(player.accept_movement_input):
		direction = Input.get_axis("overworld_move_left", "overworld_move_right")
		change_player_sprite_direction(direction)
		player._apply_horizontal_input(delta, direction)
#endregion

func on_state_exit() -> void:
	# No behaviours needed for exiting Run state.
	pass
