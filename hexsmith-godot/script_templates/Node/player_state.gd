class_name PlayerState 
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "STATE_NAME" # Probably just for debugging
	self.state_id = 0 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered STATENAME State")
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited STATENAME State")
	# pass
