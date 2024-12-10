## Stops time, opens the pause menu, disables all other input.
class_name PlayerPauseState 
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Paused" # Probably just for debugging
	self.state_id = 2 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered Paused State")
	Engine.time_scale = 0.0
	player.hud_manager.change_active_menu(2)
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited Paused State")
	Engine.time_scale = 1.0
	# pass
