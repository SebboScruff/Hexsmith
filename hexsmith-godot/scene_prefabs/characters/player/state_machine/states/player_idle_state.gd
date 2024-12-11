## The default overworld state. The player starts as Idle, and returns if no other input
## is done.
class_name PlayerIdleState
extends PlayerState

func _init() -> void:
	self.state_name = "Idle"
	self.state_id = 0

func on_state_enter() -> void:
	print("Player entered IDLE State")
	# Set Engine Timescale to 1.0
	# Activate Overworld HUD
	# Play Idle Animation
	#pass

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	# Idle is the base overworld state, and need a big transition tree based on input:
	# Walking or Running
	if(Input.get_axis("overworld_move_left", "overworld_move_right") != 0):
		State_Transition.emit(self, "walk")
	# Jumping
	# Falling
	# Climbing
	# Swimming
	# Pre-casting a Spell
	# Pressing and Holding a Spell
	

func on_state_exit() -> void:
	print("Player exited IDLE State")
	# pass
