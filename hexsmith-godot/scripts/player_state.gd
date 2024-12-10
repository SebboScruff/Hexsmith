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
	pass
	
func on_state_exit() -> void:
	pass
