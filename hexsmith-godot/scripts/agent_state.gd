# Used in State Machines, to manage transitionary behaviours and 
# frame-by-frame processing
class_name AgentState

var state_name:String
var state_id: int

func on_state_enter() -> void:
	pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	pass
