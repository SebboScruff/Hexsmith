## Default Overworld Movement.
class_name PlayerWalkState
extends PlayerState

var direction:float

func _init() -> void:
	self.state_name = "Walk"
	self.state_id = 4

func on_state_enter() -> void:
	print("Player entered WALK State")
	player.current_speed = player.BASE_SPEED
	# Play Idle Animation
	#pass

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	
	## STATE TRANSITIONS:
	if(Input.get_axis("overworld_move_left", "overworld_move_right") == 0):
		State_Transition.emit(self, "idle")
	
	## PHYSICS BEHAVIOURS
	direction = Input.get_axis("overworld_move_left", "overworld_move_right")
	## NOTE: Sprite "flipping" is done via x-axis scale to make sure attack hitboxes spawn in the right place.
	if direction > 0:
		player.body_sprite.scale.x = 1
	elif direction < 0:
		player.body_sprite.scale.x = -1
	# else direction is exactly 0 (i.e. no input) and sprite should stay in current orientation

func on_state_exit() -> void:
	print("Player exited WALK State")
	# pass
