# Used in State Machines, to manage transitionary behaviours and 
# frame-by-frame processing
class_name PlayerState
extends Node

var player:Player
var state_name:String
var state_id: int

signal State_Transition

func on_state_enter() -> void:
	pass
	
func on_state_process(delta:float) -> void:
	pass
	
func on_state_physics_process(delta:float) -> void:
	# All States require the capability to go to the following States:
	# 1 - System Pause
	if(Input.is_action_just_pressed("global_system_pause")):
		State_Transition.emit(self, "paused")
	# 2 - Loadout Pause
	if(Input.is_action_just_pressed("global_loadout_pause")):
		State_Transition.emit(self, "loadout")
	# 3 - Spellcraft (if not paused)
	if(!player.is_paused && Input.is_action_just_pressed("toggle_spellcraft_menu")):
		State_Transition.emit(self, "spellcraft")
	# 4 - Cutscene/ Dialogue
	pass
	
func on_state_exit() -> void:
	pass
