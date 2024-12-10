## The faster movement state. Probably can be removed honestly, unless there's an actually
## compelling reason to use both movement speeds at different points in the game. Don't especially
## want to make a stamina system cuz it feels like clutter
class_name PlayerRunState 
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Run" # Probably just for debugging
	self.state_id = 5 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered Running State")
	# TODO Play Running Animation
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited Running State")
	# pass
