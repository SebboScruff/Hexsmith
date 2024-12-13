## The default overworld state. The player starts as Idle, and returns if no other input
## is done.
class_name PlayerIdleState
extends PlayerState

func _init() -> void:
	self.state_name = "Idle"
	self.state_id = 0

func on_state_enter() -> void:
	player.can_cast = true
	player.gravity_scale = 1.0
	# Set Engine Timescale to 1.0
	Engine.time_scale = 1.0
	# Activate Overworld HUD
	hud_manager.change_active_menu(hud_manager.overworld_hud)
	# Play Idle Animation
	player.body_sprite.play("idle")

func on_state_process(delta:float) -> void:
	super.on_state_process(delta)

func on_state_physics_process(delta:float) -> void:
	super.on_state_physics_process(delta)
#region State Transitions
	## 1 - Walking or Running
	if(Input.get_axis("overworld_move_left", "overworld_move_right") != 0):
		if(Input.is_action_pressed("overworld_toggle_sprint")):
			State_Transition.emit(self, "run")
		else:
			State_Transition.emit(self, "walk")
	## 2 - Crouching/ crawling
	elif(player.is_on_floor() && Input.is_action_just_pressed("overworld_down")):
		State_Transition.emit(self, "crawl")
	## 3 - Jumping
	elif(Input.is_action_pressed("overworld_jump")):
		if(player.is_on_floor() || player.can_surface):
			State_Transition.emit(self, "jump")
	## 4 - Falling
	elif(!player.is_on_floor && player.velocity.y > 0):
		State_Transition.emit(self, "fall")
	## 5 - Climbing
	elif(player.is_climbing):
		State_Transition.emit(self, "climb")
	## 6 - Swimming
	elif(player.is_swimming):
		State_Transition.emit(self, "swim")
	## 7 - Basic Melee Attack
	elif(player.is_melee_ready && Input.is_action_just_pressed("overworld_melee_attack")):
		State_Transition.emit(self, "basic melee")
	## 8 - Casting a Spell - has different Transitions based on the spell type and hotkey
	# TODO Look into this and try to make it look less bad
	check_spellcast_transitions() ## NOTE: Function Body in base class, player_state.gd
#endregion
	
	## STANDARD PHYSICS BEHAVIOURS
	player._apply_gravity(delta)
	player.move_and_slide()

func on_state_exit() -> void:
	# No exit behaviours needed for leaving Idle
	pass
