# Used in State Machines, to manage transitionary behaviours and 
# frame-by-frame processing
class_name PlayerState
extends Node

@export var player:Player
@export var hud_manager:HudManager
var state_name:String
var state_id: int

signal State_Transition

func on_state_enter() -> void:
	pass
	
@warning_ignore("unused_parameter")
func on_state_process(delta:float) -> void:
	pass
	
@warning_ignore("unused_parameter")
func on_state_physics_process(delta:float) -> void:
	# All States require the capability to go to the following States:
	# 1 - System Pause
	if(Input.is_action_just_pressed("global_system_pause")):
		State_Transition.emit(self, "paused")
	# 2 - Loadout Pause
	elif(Input.is_action_just_pressed("global_loadout_pause")):
		State_Transition.emit(self, "paused")
	# 3 - Spellcraft (if not paused)
	elif(!player.is_paused && Input.is_action_just_pressed("toggle_spellcraft_menu")):
		State_Transition.emit(self, "spellcraft")
	# 4 - Cutscene/ Dialogue
	#TODO Add generic transition into cutscenes and dialogue
	
func on_state_exit() -> void:
	pass
