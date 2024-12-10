## If using a PRESS_AND_HOLD spell, the player can only move the cursor and release the hotkey.
## Left/Right movement is disabled, but the player will still move due to external effects.
class_name PlayerSpellHoldState 
extends AgentState

var player:Player

func _init(_player:Player) -> void:
	self.state_name = "Spell Hold" # Probably just for debugging
	self.state_id = 0 # Set this for lookup tables
	self.player = _player
	
func on_state_enter() -> void:
	print("Player entered Spell Hold State")
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited STATENAME State")
	# pass
