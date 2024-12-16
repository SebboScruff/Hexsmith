## Default Overworld Movement.
class_name PlayerWalkState
extends PlayerState

var direction:float

func _init() -> void:
	self.state_name = "Walk"
	self.state_id = 4

func on_state_enter() -> void:
	player.current_speed = player.BASE_SPEED
	player.body_sprite.play("run") # TODO Change this to walk animation rather than run

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
	
#region State Transitions
	# Idle
	if(Input.get_axis("overworld_move_left", "overworld_move_right") == 0):
		State_Transition.emit(self, "idle")
	# Run
	elif(Input.is_action_pressed("overworld_toggle_sprint")):
		State_Transition.emit(self, "run")
	# Jump
	elif(Input.is_action_just_pressed("overworld_jump")):
		State_Transition.emit(self, "jump")
	# Fall
	elif(!player.is_on_floor()):
		State_Transition.emit(self, "fall")
	# Crawl
	elif(player.is_on_floor() && Input.is_action_just_pressed("overworld_down")):
		State_Transition.emit(self, "crawl")
	# Climb
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
#endregion

#region PHYSICS BEHAVIOURS
	player._apply_gravity(delta)
	if(player.accept_movement_input):
		direction = Input.get_axis("overworld_move_left", "overworld_move_right")
		## NOTE: Function Body in base class, player_state.gd
		change_player_sprite_direction(direction)
		player._apply_horizontal_input(delta, direction)
#endregion

func on_state_exit() -> void:
	# No behaviours needed for exiting Walk
	pass
