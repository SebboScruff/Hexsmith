## Default Overworld Movement.
class_name PlayerWalkState
extends PlayerState

func _init() -> void:
	self.state_name = "Walk"
	self.state_id = 4

func on_state_enter() -> void:
	print("Player entered WALK State")
	# Set Engine Timescale to 1.0
	# Activate Overworld HUD
	# Play Idle Animation
	#pass

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	
	if(Input.get_axis("overworld_move_left", "overworld_move_right") == 0):
		State_Transition.emit(self, "idle")
	pass

func on_state_exit() -> void:
	print("Player exited WALK State")
	# pass
