class_name StateMachineRunner
extends Node2D

var current_state:AgentState

func _process(delta: float) -> void:
	current_state.on_state_process()
	
func _physics_process(delta: float) -> void:
	current_state.on_state_physics_process()

func change_state(new_state:AgentState):
	if(current_state != null):
		current_state.on_state_exit()
	current_state = new_state
	current_state.on_state_enter()
