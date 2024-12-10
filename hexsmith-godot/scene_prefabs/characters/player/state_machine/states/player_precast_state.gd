## Entered when the player uses a SINGLE_CAST spell, between key-up and key-down. Makes the cursor 
## visible and allows only the casting of the pre-casted spell.
class_name PlayerPrecastState 
extends AgentState

var player:Player
var spell_index:int

func _init(_player:Player, _spell_slot_index:int) -> void:
	self.state_name = "Pre-cast" # Probably just for debugging
	self.state_id = 9 # Set this for lookup tables
	self.player = _player
	self.spell_index = _spell_slot_index # so that the player can only cast the spell that they are precasting
	
func on_state_enter() -> void:
	print("Player entered Precast State")
	#pass
	
func on_state_process() -> void:
	pass
	
func on_state_physics_process() -> void:
	pass
	
func on_state_exit() -> void:
	print("Player exited Precast State")
	# pass
