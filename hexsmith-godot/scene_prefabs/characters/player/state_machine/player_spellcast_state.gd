## Middle-state for inheritance chain, to manage everything in between key down and 
## key up. Requires different behavioural states depending on which cast type the chosen spell
## has. Manages generic behaviours like moving while casting, turning the player based on 
## cast direction, and 

## NOTE: In order to perform a State Transition, call the following function:
## State_Transition.emit(self, "new_state_name")
## where new_state_name is all in lowercase and is the new state's state_name variable.

class_name PlayerSpellcastState
extends PlayerState

var spell_slot_index:int  # which spell is being casted

var cast_direction:float # angle between player and crosshair

var h_dir:float # allow for movement input
var can_move:bool # whether or not the player can move

func _init() -> void:
	self.state_name = "SpellcastBase" # This is used as the dictionary Key
	self.state_id = 16 

## All behaviours that take place as the player enters this state go here,
## for example changing the HUD Style, setting bools, altering the game's Time Scale, or
## Removing Momentum.
func on_state_enter() -> void:
	hud_manager.set_spell_slot_highlight(spell_slot_index, true)
	# pass

## Anything that the state does that doesn't care about stable update rate goes here.
func on_state_process(delta:float) -> void:
	super.on_state_process(delta)
	

## If the state has processes that need stable update rate, like
## Input processing or movement, put them in here.
func on_state_physics_process(delta:float) -> void:
	#NOTE: This is so that all States can transition into Pause, Spellcraft, or Cutscene.
	super.on_state_physics_process(delta)
#region STATE TRANSITIONS
	
#endregion
	
#region PHYSICS BEHAVIOURS
	
#endregion

func on_state_exit() -> void:
	hud_manager.set_spell_slot_highlight(spell_slot_index, false)
	# pass
