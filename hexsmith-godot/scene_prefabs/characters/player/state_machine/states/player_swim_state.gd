## Activated when underwater. Drains oxygen, reduces gravity, and slows movement speed.
class_name PlayerSwimState 
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Swim" # Probably just for debugging
	self.state_id = 8 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered Swimming State")
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited Swimming State")
	# pass
